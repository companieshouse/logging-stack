resource "aws_instance" "nodes" {
  for_each = local.instance_definitions

  ami                    = data.aws_ami.elasticsearch[each.value.ami_version_pattern].id
  iam_instance_profile   = data.aws_iam_instance_profile.elastic_search_node.name
  instance_type          = each.value.instance_type
  key_name               = var.ssh_keyname
  subnet_id              = var.subnets[each.value.availability_zone].id
  user_data_base64       = data.template_cloudinit_config.configs[each.key].rendered
  vpc_security_group_ids = [data.aws_security_group.elasticsearch.id]

  root_block_device {
    volume_size = var.root_volume_size != 0 ? var.root_volume_size : local.ami_root_block_devices[each.value.ami_version_pattern].ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices[each.value.ami_version_pattern]
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

  tags = merge(
    {
        for role in var.roles:
          lookup(var.role_tags, role) => true if contains(keys(var.role_tags), role)
    },
    {
      Environment = var.environment
      HostName    = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${each.key}.${var.dns_zone_name}"
      Name        = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${each.key}"
      Service     = var.service
    }
  )
}

resource "aws_lb_target_group_attachment" "elasticsearch_api" {
  for_each = var.elasticsearch_api_target_group_arn == null ? {} : local.instance_definitions

  target_group_arn  = var.elasticsearch_api_target_group_arn
  target_id         = aws_instance.nodes[each.key].private_ip
  port              = 9200
}

resource "aws_lb_target_group_attachment" "elasticsearch_cluster" {
  for_each = var.elasticsearch_cluster_target_group_arn == null ? {} : local.instance_definitions

  target_group_arn  = var.elasticsearch_cluster_target_group_arn
  target_id         = aws_instance.nodes[each.key].private_ip
  port              = 9200
}
