locals {
  ami_lvm_block_devices = {
    for pattern, ami in data.aws_ami.elasticsearch : pattern => [
      for block_device in ami.block_device_mappings :
        block_device if block_device.device_name != ami.root_device_name
    ]
  }

  ami_root_block_devices = {
    for pattern, ami in data.aws_ami.elasticsearch : pattern =>
      tolist(ami.block_device_mappings)[index(
        ami.block_device_mappings.*.device_name,
        ami.root_device_name)
      ]
  }

  specification_ami_version_patterns = toset(
    concat(flatten([
      for availability_zone, instances in var.instance_specifications : [
        for id, specification in instances : specification.ami_version_pattern
          if contains(keys(specification), "ami_version_pattern")
      ]]),
      ["\\d.\\d.\\d"]
    )
  )

  instance_definitions = merge([
    for availability_zone, instances in var.instance_specifications : {
      for id, specification in instances : id => {
        ami_version_pattern = lookup(specification, "ami_version_pattern", var.default_ami_version_pattern)
        instance_type     = lookup(specification, "instance_type", var.default_instance_type)
        availability_zone = availability_zone
      }
    }
  ]...)

  log_group_name = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}"

}
