config {
  plugin_dir          = "~/.tflint.d/plugins"
  force               = false
  call_module_type    = "local"
  disabled_by_default = false
  format              = "json"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.39.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Project",
    "Environment",
    "ManagedBy",
  ]
}
