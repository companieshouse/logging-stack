variable "user_data_merge_strategy" {
  default     = "list(append)+dict(recurse_array)+str()"
  description = "Merge strategy to apply to user-data sections for cloud-init"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_hostname = var.instance_hostname
    })
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch.root_device_name
    })
  }
}
