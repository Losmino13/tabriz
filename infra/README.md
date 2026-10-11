Infrastructure for Devops task got from Tabz company

One page site taken from: https://github.com/Md-Saad/portfolio-theme


Deploying infrastructure and site

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

Step-by-step deployment: [../README.md](../README.md)

Document and tools used references:

https://hub.docker.com/_/nginx/


https://docs.terragrunt.com/getting-started/quick-start/


https://claude.ai
