locals {
  ami_version_patterns = toset([
    var.data_cold_ami_version_pattern,
    var.data_hot_ami_version_pattern,
    var.data_warm_ami_version_pattern,
    var.master_ami_version_pattern
  ])

  ami_lvm_block_devices = {
    for pattern in local.ami_version_patterns : pattern => [
      for block_device in data.aws_ami.elasticsearch[pattern].block_device_mappings :
        block_device if block_device.device_name != data.aws_ami.elasticsearch[pattern].root_device_name
      ]
  }

  ami_root_block_device = {
    for pattern in local.ami_version_patterns : pattern =>
      tolist(data.aws_ami.elasticsearch[pattern].block_device_mappings)[index(data.aws_ami.elasticsearch[pattern].block_device_mappings.*.device_name, data.aws_ami.elasticsearch[pattern].root_device_name)]
  }

  cold_nodes_log_group_name = "${var.service}-${var.environment}-cold-nodes"
  hot_nodes_log_group_name = "${var.service}-${var.environment}-hot-nodes"
  master_nodes_log_group_name = "${var.service}-${var.environment}-master-nodes"
  warm_nodes_log_group_name = "${var.service}-${var.environment}-warm-nodes"
}
