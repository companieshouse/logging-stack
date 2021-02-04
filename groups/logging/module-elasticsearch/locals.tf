locals {
  ami_root_block_device = tolist(data.aws_ami.elasticsearch.block_device_mappings)[index(data.aws_ami.elasticsearch.block_device_mappings.*.device_name, data.aws_ami.elasticsearch.root_device_name)]
  ami_lvm_block_devices = [
    for block_device in data.aws_ami.elasticsearch.block_device_mappings :
      block_device if block_device.device_name != data.aws_ami.elasticsearch.root_device_name
  ]
}
