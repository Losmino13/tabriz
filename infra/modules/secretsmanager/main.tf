ephemeral "random_password" "this" {
  for_each = { for k, v in var.secrets : k => v if v.generate_password }

  length           = each.value.password_length
  special          = true
  override_special = each.value.password_special
}

module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 2.0"

  for_each = var.secrets

  name                    = "${local.name_prefix}/${each.key}"
  description             = each.value.description
  recovery_window_in_days = var.recovery_window_in_days
  enable_rotation         = false

  secret_string_wo = jsonencode(merge(
    each.value.values,
    each.value.username != null ? { username = each.value.username } : {},
    each.value.generate_password ? { (each.value.password_key) = ephemeral.random_password.this[each.key].result } : {},
  ))
  secret_string_wo_version = var.secret_version

  tags = var.tags
}
