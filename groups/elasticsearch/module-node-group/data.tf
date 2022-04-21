data "aws_ami" "elasticsearch" {
  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}

data "aws_route53_zone" "zone" {
  count        = var.route53_available ? 1 : 0

  name         = var.dns_zone_name
  private_zone = false
}

data "template_cloudinit_config" "configs" {
  count         = var.instance_count

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_fqdn = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${count.index + 1}.${var.dns_zone_name}"
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = element(var.availability_zones, count.index)
      box_type                      = var.box_type
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch.root_device_name
    })
    # TODO - Revert me
    # merge_type = var.user_data_merge_strategy
    merge_type = var.bootstrap_user_data_merge_strategy
  }
}
