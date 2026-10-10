locals {
  name          = "${var.project}-${var.env}"
  https_enabled = var.certificate_arn != null

  ingress_ports = local.https_enabled ? { http = 80, https = 443 } : { http = 80 }
}
