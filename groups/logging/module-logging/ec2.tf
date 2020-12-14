resource "aws_security_group" "logging" {
  name   ="${var.service}-${var.environment}-security-group"
  vpc_id = var.vpc_id

  ingress {
    description = "Inbound SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-security-group"
    Environment = var.environment
    Service     = var.service
  }
}

data "aws_ami" "elasticsearch" {
  owners      = ["self"]
  most_recent = true
  name_regex  = "^elasticsearch-ami-\\d.\\d.\\d"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-${var.ami_version_pattern}"]
  }
}

locals {
  root_block_device = tolist(data.aws_ami.elasticsearch.block_device_mappings)[index(data.aws_ami.elasticsearch.block_device_mappings.*.device_name, data.aws_ami.elasticsearch.root_device_name)]
  lvm_block_devices = [
    for block_device in data.aws_ami.elasticsearch.block_device_mappings :
      block_device if block_device.device_name != data.aws_ami.elasticsearch.root_device_name
  ]
}

resource "aws_instance" "logging" {
  ami                    = data.aws_ami.elasticsearch.id
  instance_type          = var.instance_type
  subnet_id              = var.application_subnet
  key_name               = var.ssh_keyname
  vpc_security_group_ids = [aws_security_group.logging.id]
  user_data_base64       = "${data.template_cloudinit_config.config.rendered}"

  root_block_device {
    volume_size = var.root_volume_size != 0 ? var.root_volume_size : local.root_block_device.ebs.volume_size
  }

  dynamic "ebs_block_device" {
    for_each = local.lvm_block_devices
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
    Name         = "${var.service}-${var.environment}"
    Environment  = var.environment
    Service      = var.service
  }

  volume_tags = {
    Name         = "${var.service}-${var.environment}-ebs-volume"
    Environment  = var.environment
    Service      = var.service
  }
}
