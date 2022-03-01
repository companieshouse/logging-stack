data "aws_ami" "kibana" {
  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = "^kibana-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["kibana-ami-*"]
  }
}

data "template_cloudinit_config" "kibana" {
  count         = var.instance_count

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {
      instance_fqdn = "${var.service}-${var.environment}-kibana-${count.index + 1}.${var.dns_zone_name}"
    })
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/amazon-cloudwatch-agent.tpl", {
      region         = var.region
      log_group_name = local.log_group_name
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud-init/templates/amazon-cloudwatch-metrics.tpl", {
      metrics_namespace = "${var.service}-${var.environment}-kibana"
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      discovery_availability_zones  = var.discovery_availability_zones
      elastic_search_service_user   = var.elastic_search_service_user
      elastic_search_service_group  = var.elastic_search_service_group
      environment                   = var.environment
      region                        = var.region
      roles                         = var.roles
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/kibana.yml.tpl", {
      kibana_service_user   = var.kibana_service_user
      kibana_service_group  = var.kibana_service_group
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.lvm_block_devices
      root_volume_device_node = data.aws_ami.kibana.root_device_name
    })
  }
}

resource "aws_instance" "kibana" {
  count                  = var.instance_count

  ami                    = data.aws_ami.kibana.id
  iam_instance_profile   = var.instance_profile_name
  instance_type          = var.instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.kibana[count.index].rendered
  vpc_security_group_ids = [
    data.aws_security_group.elasticsearch.id,
    aws_security_group.kibana_instances.id
  ]

  root_block_device {
    volume_size = var.root_volume_size != 0 ? var.root_volume_size : local.ami_root_block_device.ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices
    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.lvm_block_devices[index(var.lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  tags = {
    Application = "kibana"
    Environment = var.environment
    HostName    = "${var.service}-${var.environment}-kibana-${count.index + 1}.${var.dns_zone_name}"
    Name        = "${var.service}-${var.environment}-kibana-${count.index + 1}"
    Service     = var.service
  }
}
