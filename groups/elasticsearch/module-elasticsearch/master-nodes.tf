data "template_cloudinit_config" "master" {
  count         = var.master_instance_count

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_fqdn = "${var.service}-${var.environment}-${var.deployment}-master-${count.index + 1}.${var.dns_zone_name}"
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = null
      box_type                      = "master"
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.master_roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.master_instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.master_lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.master_ami_version_pattern].root_device_name
    })
  }
}

resource "aws_instance" "master" {
  count                  = var.master_instance_count

  ami                    = data.aws_ami.elasticsearch[var.master_ami_version_pattern].id
  iam_instance_profile   = var.master_instance_profile_name
  instance_type          = var.master_instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.master[count.index].rendered
  vpc_security_group_ids = [data.aws_security_group.elasticsearch.id]

  root_block_device {
    volume_size = var.master_root_volume_size != 0 ? var.master_root_volume_size : local.ami_root_block_device[var.master_ami_version_pattern].ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices[var.master_ami_version_pattern]
    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.master_lvm_block_devices[index(var.master_lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  tags = merge(
    {
      for role in var.master_roles:
        lookup(var.role_tags, role) => true if contains(keys(var.role_tags), role)
    },
    {
      Environment             = var.environment
      HostName                = "${var.service}-${var.environment}-${var.deployment}-master-${count.index + 1}.${var.dns_zone_name}"
      ElasticSearchMasterNode = "true"
      Name                    = "${var.service}-${var.environment}-${var.deployment}-master-${count.index + 1}"
      Service                 = var.service
    }
  )
}
