# Infrastructure for Devops task got from Tabz company

One page site used from: https://github.com/Md-Saad/portfolio-theme


Infra directory structure:

```
.
├── root.hcl                 # S3 remote state, AWS provider, common inputs
├── global                   # account-wide, shared by dev and prod
│   ├── env.hcl
│   └── github-oidc
├── dev
│   ├── env.hcl              # dev settings
│   ├── alb
│   ├── ecr
│   ├── ecs
│   ├── iam
│   ├── secretsmanager
│   └── vpc
├── prod
│   ├── env.hcl              # prod settings
│   ├── alb
│   ├── ecr
│   ├── ecs
│   ├── iam
│   ├── secretsmanager
│   └── vpc
└── modules
    ├── alb
    ├── ecr
    ├── ecs
    ├── github-oidc
    ├── iam
    ├── secretsmanager
    └── vpc
```


Document and tools used references:

- https://hub.docker.com/_/nginx/
- https://docs.terragrunt.com/getting-started/quick-start/
- https://docs.terragrunt.com/reference/hcl/blocks/#mock-outputs
- https://docs.terragrunt.com/reference/hcl/functions/
- https://developer.hashicorp.com/terraform/language/functions
- https://github.com/Md-Saad/portfolio-theme

AI helper:

- https://claude.ai


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

## 4. Prod

```bash
cd infra/prod
terragrunt run --all plan
terragrunt run --all apply

(cd alb && terragrunt output -raw alb_dns_name)
```

Both environments use a single NAT gateway.

Prod should differs from dev but for cost reasons some of these differences are turned off. Container Insights on, Fargate only (no Spot), imutable image tags, ALB deletion protection, 2 tasks with CPU autoscaling (2–6 tasks, +1 at CPU ≥ 80 %, −1 at CPU ≤ 10 %).

## 5. GitHub setup (once)

1. Repository → Settings → Environments → create `dev` and `prod`.
2. In each environment add the variable `AWS_ROLE_ARN` = `github_deploy_role_arn` output of that environment's `iam` unit.

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


## 8. Redis (ElastiCache, not managed here)

The network path from the ECS tasks to Redis is prepared. When the replication group is created:

- attach security group `redis_security_group_id` (`infra/<env>/vpc` output),
- use a subnet group built from `database_subnets` (`infra/<env>/vpc` output),
- enable `transit_encryption_enabled` and use `auth_token` from secret `tabriz/<env>/redis`,
- replace the placeholder `host` in `secrets.redis.values` in `infra/<env>/env.hcl` with the primary endpoint, bump `secret_version` and apply `infra/<env>/secretsmanager`. This also regenerates `auth_token`.

## 9. Tear down

```bash
cd infra/dev
terragrunt run --all destroy
```
