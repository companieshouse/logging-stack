locals {
  ami_root_block_device = tolist(data.aws_ami.kibana.block_device_mappings)[index(data.aws_ami.kibana.block_device_mappings.*.device_name, data.aws_ami.kibana.root_device_name)]
  ami_lvm_block_devices = [
    for block_device in data.aws_ami.kibana.block_device_mappings :
      block_device if block_device.device_name != data.aws_ami.kibana.root_device_name
  ]
  certificate_arn = var.route53_available ? aws_acm_certificate_validation.certificate[0].certificate_arn : var.certificate_arn

  log_group_name       = "${var.service}-${var.environment}-kibana"
}
