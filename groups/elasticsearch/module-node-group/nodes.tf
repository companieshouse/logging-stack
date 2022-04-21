resource "aws_instance" "nodes" {
  count                  = var.instance_count

  ami                    = data.aws_ami.elasticsearch.id
  iam_instance_profile   = data.aws_iam_instance_profile.elastic_search_node.name
  instance_type          = var.instance_type
  key_name               = var.ssh_keyname
  subnet_id              = element(var.subnet_ids, count.index)
  user_data_base64       = data.template_cloudinit_config.configs[count.index].rendered
  vpc_security_group_ids = [data.aws_security_group.elasticsearch.id]

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

  tags = merge(
    {
        for role in var.roles:
          lookup(var.role_tags, role) => true if contains(keys(var.role_tags), role)
    },
    {
      Environment = var.environment
      HostName    = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${count.index + 1}.${var.dns_zone_name}"
      Name        = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${count.index + 1}"
      Service     = var.service
    }
  )
}

resource "aws_lb_target_group_attachment" "elasticsearch_api" {
  count             = var.elasticsearch_api_target_group_arn == null ? 0 : var.instance_count

  target_group_arn  = var.elasticsearch_api_target_group_arn
  target_id         = aws_instance.nodes[count.index].private_ip
  port              = 9200
}
