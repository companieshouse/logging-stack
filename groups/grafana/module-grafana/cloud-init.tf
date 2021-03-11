data "template_cloudinit_config" "grafana" {
  count         = var.instance_count
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "#cloud-config"
  }

  part {
    content_type    =   "text/cloud-config"
    content         =   templatefile("${path.module}/cloud-init/files/bootstrap-commands.yml", {
      hostname      =   "${var.environment}-${var.service}-grafana${count.index+1}"
    })
  }
}
