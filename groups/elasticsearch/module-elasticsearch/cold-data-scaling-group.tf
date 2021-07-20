resource "aws_launch_configuration" "cold_data" {
  for_each = var.asg_availability_zones

  name_prefix          = "${var.service}-${var.environment}-cold-${each.value}-"
  image_id             = data.aws_ami.elasticsearch[var.scaling_group_configuration[each.value].cold.ami_version_pattern].id
  instance_type        = var.scaling_group_configuration[each.value].cold.instance_type
  iam_instance_profile = data.aws_iam_instance_profile.elastic_search_node.name
  key_name             = var.ssh_keyname
  security_groups      = [data.aws_security_group.elasticsearch.id]
  user_data_base64     = data.template_cloudinit_config.cold_data[each.value].rendered

  root_block_device {
    volume_size = var.scaling_group_configuration[each.value].cold.root_volume_size != 0 ? var.scaling_group_configuration[each.value].cold.root_volume_size : local.ami_root_block_device_by_pattern[var.scaling_group_configuration[each.value].cold.ami_version_pattern].ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.ami_lvm_block_devices_by_pattern[var.scaling_group_configuration[each.value].cold.ami_version_pattern]

    iterator = block_device
    content {
      device_name = block_device.value.device_name
      encrypted   = block_device.value.ebs.encrypted
      iops        = block_device.value.ebs.iops
      snapshot_id = block_device.value.ebs.snapshot_id
      volume_size = var.scaling_group_configuration[each.value].cold.lvm_block_devices[index(var.scaling_group_configuration[each.value].cold.lvm_block_devices.*.lvm_physical_volume_device_node, block_device.value.device_name)].aws_volume_size_gb
      volume_type = block_device.value.ebs.volume_type
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cold_data" {
  for_each = var.asg_availability_zones

  name                 = "${var.service}-${var.environment}-cold-${each.value}"
  launch_configuration = aws_launch_configuration.cold_data[each.value].name
  desired_capacity     = var.scaling_group_configuration[each.value].cold.node_count
  min_size             = var.scaling_group_configuration[each.value].cold.node_count
  max_size             = var.scaling_group_configuration[each.value].cold.node_count
  tags = concat(
  [
    for role in var.data_cold_roles: {
      key = lookup(var.role_tags, role)
      value = contains(keys(var.role_tags), role)
      propagate_at_launch = true
    }
  ],
  [
    {
      key = "Environment"
      value = var.environment
      propagate_at_launch = true
    },
    {
      key = "Name"
      value = "${var.service}-${var.environment}-cold-${each.value}"
      propagate_at_launch = true
    },
    {
      key = "Service"
      value = var.service
      propagate_at_launch = true
    }
  ])

  vpc_zone_identifier  = [var.asg_subnet_ids_by_availability_zone[each.value]]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}
