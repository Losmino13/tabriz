# Ephemeral: the generated password is written to Secrets Manager but never stored in state.
ephemeral "random_password" "this" {
  for_each = { for k, v in var.secrets : k => v if v.generate_password }

  length           = each.value.password_length
  special          = true
  override_special = "@#$%^&*()_+"
}

module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 2"

  for_each = var.secrets

  name                    = "${local.name_prefix}/${each.key}"
  description             = each.value.description
  recovery_window_in_days = var.recovery_window_in_days
  enable_rotation         = false

  secret_string_wo = jsonencode({
    username = each.value.username
    password = each.value.generate_password ? ephemeral.random_password.this[each.key].result : null
  })
  secret_string_wo_version = var.secret_version

  tags = var.tags
}
