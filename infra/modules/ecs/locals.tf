locals {
  name         = "${var.project}-${var.env}"
  service_name = "${local.name}-${var.service_name}"
}
