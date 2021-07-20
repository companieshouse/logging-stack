locals {
  ami_root_block_device = tolist(data.aws_ami.elasticsearch[var.ami_version_pattern].block_device_mappings)[index(data.aws_ami.elasticsearch[var.ami_version_pattern].block_device_mappings.*.device_name, data.aws_ami.elasticsearch[var.ami_version_pattern].root_device_name)]

  ami_lvm_block_devices = [
    for block_device in data.aws_ami.elasticsearch[var.ami_version_pattern].block_device_mappings :
      block_device if block_device.device_name != data.aws_ami.elasticsearch[var.ami_version_pattern].root_device_name
  ]

  ami_root_block_device_by_pattern = {
    for pattern in var.ami_version_patterns : pattern => tolist(data.aws_ami.elasticsearch[pattern].block_device_mappings)[index(data.aws_ami.elasticsearch[pattern].block_device_mappings.*.device_name, data.aws_ami.elasticsearch[pattern].root_device_name)]
  }

  ami_lvm_block_devices_by_pattern = {
    for pattern in var.ami_version_patterns : pattern => [
      for block_device in data.aws_ami.elasticsearch[pattern].block_device_mappings :
        block_device if block_device.device_name != data.aws_ami.elasticsearch[pattern].root_device_name
    ]
  }
}
