data "aws_ami" "elasticsearch" {
  for_each = var.ami_version_patterns

  owners      = ["${var.ami_owner_id}"]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${each.value}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}

data "aws_iam_instance_profile" "elastic_search_node" {
  name = "${var.service}-${var.environment}-elastic-search"
}

data "template_cloudinit_config" "cold_data" {
  for_each = var.asg_availability_zones

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = each.value
      box_type                      = "cold"
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.data_cold_roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.data_cold_instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.data_cold_lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.ami_version_pattern].root_device_name
    })
    merge_type = var.user_data_merge_strategy
  }
}

# ------------------------------------------------------------------------------
# Auto Scaling Group
# ------------------------------------------------------------------------------
data "template_cloudinit_config" "cold_data_asg" {
  for_each = var.asg_availability_zones

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = each.value
      box_type                      = "cold"
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.data_cold_roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.data_cold_instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.scaling_group_configuration[each.value].cold.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.scaling_group_configuration[each.value].cold.ami_version_pattern].root_device_name

    })
    merge_type = var.user_data_merge_strategy
  }
}

data "template_cloudinit_config" "hot_data_asg" {
  for_each = var.asg_availability_zones

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = each.value
      box_type                      = "hot"
      discovery_availability_zones  = var.discovery_availability_zones
      environment                   = var.environment
      region                        = var.region
      roles                         = var.data_hot_roles
      service_group                 = var.service_group
      service_user                  = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/jvm.options.tpl", {
      heap_size_gigabytes   = var.instance_type_heap_allocation[var.data_hot_instance_type]
      service_group         = var.service_group
      service_user          = var.service_user
    })
    merge_type = var.user_data_merge_strategy
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      lvm_block_devices       = var.scaling_group_configuration[each.value].hot.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.scaling_group_configuration[each.value].hot.ami_version_pattern].root_device_name

    })
    merge_type = var.user_data_merge_strategy
  }
}

data "template_cloudinit_config" "master_asg" {
  for_each = var.asg_availability_zones

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = each.value
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
      lvm_block_devices       = var.scaling_group_configuration[each.value].master.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.scaling_group_configuration[each.value].master.ami_version_pattern].root_device_name

    })
    merge_type = var.user_data_merge_strategy
  }
}

data "template_cloudinit_config" "warm_data_asg" {
  for_each = var.asg_availability_zones

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/elasticsearch.yml.tpl", {
      availability_zone             = each.value
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
      lvm_block_devices       = var.scaling_group_configuration[each.value].warm.lvm_block_devices
      root_volume_device_node = data.aws_ami.elasticsearch[var.scaling_group_configuration[each.value].warm.ami_version_pattern].root_device_name

    })
    merge_type = var.user_data_merge_strategy
  }
}
