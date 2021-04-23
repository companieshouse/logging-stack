data "template_cloudinit_config" "data_cold" {
  count         = "${var.data_cold_instance_count}"

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_fqdn = "${var.service}-${var.environment}-data-cold-${count.index + 1}.${var.dns_zone_name}"
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      box_type                      = "cold"
      discovery_availability_zones  = var.discovery_availability_zones
      elastic_search_service_user   = var.elastic_search_service_user
      elastic_search_service_group  = var.elastic_search_service_group
      environment                   = var.environment
      region                        = var.region
      roles                         = var.data_cold_roles
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      elastic_search_service_user   = var.elastic_search_service_user
      elastic_search_service_group  = var.elastic_search_service_group
      heap_size_gigabytes           = var.data_cold_heap_size_gigabytes
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.data_cold_lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch.root_device_name
    })
    merge_type = var.user_data_merge_strategy
  }
}

resource "aws_instance" "data_cold" {
  count                  = var.data_cold_instance_count

  ami                    = data.aws_ami.elasticsearch.id
  iam_instance_profile   = data.aws_iam_instance_profile.elastic_search_node.name
  instance_type          = var.data_cold_instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.data_cold[count.index].rendered
  vpc_security_group_ids = [data.aws_security_group.elasticsearch.id]

  root_block_device {
    volume_size = var.data_cold_root_volume_size != 0 ? var.data_cold_root_volume_size : local.ami_root_block_device.ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices
    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.data_cold_lvm_block_devices[index(var.data_cold_lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  tags = merge(
    {
        for role in var.data_cold_roles:
          lookup(var.role_tags, role) => true if contains(keys(var.role_tags), role)
    },
    {
      Environment   = var.environment
      HostName      = "${var.service}-${var.environment}-data-cold-${count.index + 1}.${var.dns_zone_name}"
      Name          = "${var.service}-${var.environment}-data-cold-${count.index + 1}"
      Service       = var.service
    }
  )
}
