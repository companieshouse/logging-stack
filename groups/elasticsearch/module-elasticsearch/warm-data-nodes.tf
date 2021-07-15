data "template_cloudinit_config" "data_warm" {
  count         = "${var.data_warm_instance_count}"

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_fqdn = "${var.service}-${var.environment}-data-warm-${count.index + 1}.${var.dns_zone_name}"
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = element(var.availability_zones, count.index)
      box_type                      = "warm"
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.data_warm_roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.data_warm_instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.data_warm_lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch.root_device_name
    })
    merge_type = var.user_data_merge_strategy
  }
}

resource "aws_instance" "data_warm" {
  count                  = var.data_warm_instance_count

  ami                    = data.aws_ami.elasticsearch.id
  iam_instance_profile   = data.aws_iam_instance_profile.elastic_search_node.name
  instance_type          = var.data_warm_instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.data_warm[count.index].rendered
  vpc_security_group_ids = [data.aws_security_group.elasticsearch.id]

  root_block_device {
    volume_size = var.data_warm_root_volume_size != 0 ? var.data_warm_root_volume_size : local.ami_root_block_device.ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices
    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.data_warm_lvm_block_devices[index(var.data_warm_lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  tags = merge(
    {
      for role in var.data_warm_roles:
        lookup(var.role_tags, role) => true if contains(keys(var.role_tags), role)
    },
    {
      Environment   = var.environment
      HostName      = "${var.service}-${var.environment}-data-warm-${count.index + 1}.${var.dns_zone_name}"
      Name          = "${var.service}-${var.environment}-data-warm-${count.index + 1}"
      Service       = var.service
    }
  )
}
