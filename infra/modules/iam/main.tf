module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6"

  for_each = local.roles

  name            = each.value.name
  use_name_prefix = false
  description     = each.value.description

  source_trust_policy_documents  = [data.aws_iam_policy_document.ecs_tasks_trust.json]
  create_inline_policy           = each.value.create_inline_policy
  source_inline_policy_documents = each.value.inline_policy_documents

  tags = var.tags
}
