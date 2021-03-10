data "template_cloudinit_config" "prometheus" {
  count         = var.instance_count
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "#cloud-config"
  }

  part {
    content_type              = "text/cloud-config"
    content                   = templatefile("${path.module}/cloud-init/templates/prometheus.yml.tpl", {
      prometheus_metrics_port = var.prometheus_metrics_port
      region                  = var.region
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type  = "text/cloud-config"
    content       = templatefile("${path.module}/cloud-init/files/bootstrap-commands.yml", {
    hostname      = "${var.environment}-${var.service}-prometheus${count.index+1}"
    })
  }
}
