module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  for_each = local.roles

  name            = each.value.name
  use_name_prefix = false
  description     = each.value.description

  source_trust_policy_documents  = [data.aws_iam_policy_document.ecs_tasks_trust.json]
  create_inline_policy           = each.value.create_inline_policy
  source_inline_policy_documents = each.value.inline_policy_documents

  tags = var.tags
}

module "github_deploy_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name            = "${local.name}-github-deploy"
  use_name_prefix = false
  description     = "GitHub Actions deploy role for ${local.name}: ECR push, ECS deploy"

  enable_github_oidc = true
  oidc_subjects      = ["${var.github_repository}:environment:${coalesce(var.github_environment, var.env)}"]

  create_inline_policy           = true
  source_inline_policy_documents = [data.aws_iam_policy_document.github_deploy.json]

  tags = var.tags
}
