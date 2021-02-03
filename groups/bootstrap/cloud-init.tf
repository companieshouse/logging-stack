data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_hostname = "${var.service}-${var.environment}-bootstrap.${local.dns_zone_name}"
    })
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch-master.yml.tpl", {
      discovery_availability_zones  = local.discovery_availability_zones
      dns_zone_name                 = local.dns_zone_name
      elastic_search_service_user   = var.elastic_search_service_user
      elastic_search_service_group  = var.elastic_search_service_group
      environment                   = var.environment
      region                        = var.region
      service                       = var.service
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch.root_device_name
    })
  }
}
