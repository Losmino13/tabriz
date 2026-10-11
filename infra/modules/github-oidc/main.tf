module "github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  version = "~> 6.0"

  url = "https://token.actions.githubusercontent.com"

  tags = var.tags
}
