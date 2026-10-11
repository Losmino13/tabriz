# Steps to deploy infra and app

Infrastructure: Terragrunt + Terraform, AWS `eu-central-1`, one AWS account, two environments (`dev`, `prod`).
App: static site (nginx) built by GitHub Actions, pushed to ECR, deployed to ECS Fargate behind an ALB.

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | `~> 1.15.5` |
| Terragrunt | `>= 1.0` |
| AWS CLI | v2 |

AWS credentials for the target account:

```bash
aws sso login --profile <profile>
export AWS_PROFILE=<profile>
aws sts get-caller-identity
```

## Units and order

```
global/github-oidc ─┐
<env>/ecr ──────────┼─→ <env>/iam ─┐
<env>/secretsmanager┘              │
<env>/vpc ──→ <env>/alb ───────────┼─→ <env>/ecs
<env>/vpc ─────────────────────────┘
```

| Unit | Creates |
|---|---|
| `global/github-oidc` | GitHub Actions OIDC provider (one per account, shared by dev and prod) |
| `<env>/vpc` | VPC, public / private / database subnets, NAT, Redis security group |
| `<env>/ecr` | ECR repository `tabriz-<env>/web` |
| `<env>/secretsmanager` | Secrets `tabriz/<env>/db` and `tabriz/<env>/redis` |
| `<env>/alb` | Public ALB, target group, listeners |
| `<env>/iam` | ECS task execution role, ECS task role, GitHub deploy role |
| `<env>/ecs` | ECS cluster, service `tabriz-<env>-web`, Redis ingress rule, autoscaling (prod only) |

`global/github-oidc` lives outside the environment folders, so `run --all` inside `infra/dev` or `infra/prod` does not apply it. Apply it first.

## 1. Bootstrap the state bucket (once per account)

```bash
cd infra
terragrunt backend bootstrap --all
```

Creates the S3 bucket `tabriz-tfstate-<account_id>` (versioned, encrypted, public access blocked). State is locked with S3 native lockfiles.

## 2. Global (once per account)

```bash
cd infra/global/github-oidc
terragrunt plan
terragrunt apply
```

## 3. Dev

```bash
cd infra/dev
terragrunt run --all plan
terragrunt run --all apply
```

Unit by unit instead:

```bash
cd infra/dev
for u in vpc ecr secretsmanager alb iam ecs; do
  (cd "$u" && terragrunt plan && terragrunt apply)
done
```

Outputs needed later:

```bash
cd infra/dev
(cd iam && terragrunt output -raw github_deploy_role_arn)
(cd alb && terragrunt output -raw alb_dns_name)
```

## 4. Prod

```bash
cd infra/prod
terragrunt run --all plan
terragrunt run --all apply

(cd iam && terragrunt output -raw github_deploy_role_arn)
(cd alb && terragrunt output -raw alb_dns_name)
```

Both environments use a single NAT gateway. Prod differs from dev: Container Insights on, Fargate only (no Spot), immutable image tags, ALB deletion protection, 2 tasks with CPU autoscaling (2–6 tasks, +1 at CPU ≥ 80 %, −1 at CPU ≤ 10 %).

## 5. GitHub setup (once)

1. Repository → Settings → Environments → create `dev` and `prod`.
2. In each environment add the variable `AWS_ROLE_ARN` = `github_deploy_role_arn` output of that environment's `iam` unit.
3. Optional: add required reviewers on `prod`. Build and deploy are separate jobs in the same environment, so a prod release asks for approval twice.

The deploy role can only be assumed by jobs in `Losmino13/tabriz` that run in the GitHub environment with the same name.

## 6. Deploy the app

| Goal | Workflow | Inputs |
|---|---|---|
| Build, push and deploy | **Build and Publish** | `environment`, `deploy: true` |
| Build and push only | **Build and Publish** | `environment`, `deploy: false` |
| Redeploy an existing image | **Deploy to ECS** | `environment`, `image-tag` (short commit SHA) |

What happens:

1. The image is built for `linux/amd64` and pushed to `tabriz-<env>/web:<short-sha>`. If that tag already exists, the build is skipped.
2. `tasks/task-definition.json` is rendered with the image, the IAM roles, the `DB_CREDENTIALS` / `REDIS_PARAMS` secrets and the log group `/ecs/tabriz-<env>-web`.
3. The ECS service `tabriz-<env>-web` on cluster `tabriz-<env>` is updated and the workflow waits for it to become stable.

Terraform creates the service with a placeholder `nginx` image and ignores later task definition changes, so CI/CD and Terraform do not overwrite each other.

### Build and push from your machine

```bash
export AWS_PROFILE=<profile>
scripts/build-push.sh dev            # tag = short commit SHA
scripts/build-push.sh prod my-tag    # custom tag
```

The script only pushes the image. Deploy it with the **Deploy to ECS** workflow using the printed `image-tag`.

## 7. Verify

```bash
curl -I "http://$(cd infra/dev/alb && terragrunt output -raw alb_dns_name)"
```

## 8. Exposing the site: HTTP vs HTTPS

| Option | Domain | Certificate | Status |
|---|---|---|---|
| ALB DNS name over HTTP | `tabriz-<env>-…elb.amazonaws.com` | none | **Current default** (`alb_certificate_arn = null`) |
| Own domain + ACM | e.g. `www.example.com` | ACM, free, DNS-validated | Set `alb_certificate_arn` in `env.hcl`; HTTP then redirects to HTTPS |
| CloudFront in front of the ALB | `xxxx.cloudfront.net` | CloudFront default certificate | Not implemented yet |

AWS does not issue certificates for the ALB's `*.elb.amazonaws.com` name, so HTTPS on the ALB DNS name always shows a certificate warning. HTTPS without owning a domain requires CloudFront: its `*.cloudfront.net` name comes with an AWS-managed certificate.

Enabling HTTPS with your own domain:

1. Request a public ACM certificate in `eu-central-1` for the domain and validate it via DNS.
2. Put the certificate ARN in `alb_certificate_arn` in `infra/<env>/env.hcl`.
3. `cd infra/<env>/alb && terragrunt apply`
4. Point the domain at the ALB (Route 53 alias to `alb_dns_name` / `alb_zone_id`, or a CNAME at another DNS provider).

## 9. Redis (ElastiCache, not managed here)

The network path from the ECS tasks to Redis is prepared. When the replication group is created:

- attach security group `redis_security_group_id` (`infra/<env>/vpc` output),
- use a subnet group built from `database_subnets` (`infra/<env>/vpc` output),
- enable `transit_encryption_enabled` and use `auth_token` from secret `tabriz/<env>/redis`,
- replace the placeholder `host` in `secrets.redis.values` in `infra/<env>/env.hcl` with the primary endpoint, bump `secret_version` and apply `infra/<env>/secretsmanager`. This also regenerates `auth_token`.

## 10. Tear down

```bash
cd infra/dev
terragrunt run --all destroy
```

Prod has ALB deletion protection. Disable it first:

1. Set `alb_enable_deletion_protection = false` in `infra/prod/env.hcl`.
2. `cd infra/prod/alb && terragrunt apply`
3. `cd infra/prod && terragrunt run --all destroy`

Destroy `global/github-oidc` last, after both environments are gone. ECS task definition revisions stay in AWS (`skip_destroy = true`).
