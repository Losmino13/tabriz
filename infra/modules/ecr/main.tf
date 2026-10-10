module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3"

  for_each = toset(var.repositories)

  repository_name                 = "${local.name}/${each.key}"
  repository_type                 = "private"
  repository_image_tag_mutability = var.image_tag_mutability
  repository_image_scan_on_push   = true
  repository_force_delete         = var.force_delete

  create_lifecycle_policy     = true
  repository_lifecycle_policy = local.lifecycle_policy

  tags = var.tags
}
