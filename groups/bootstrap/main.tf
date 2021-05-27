provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

data "aws_ami" "elasticsearch" {
  owners      = ["${var.ami_owner_id}"]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}

resource "aws_instance" "bootstrap" {
  ami                    = data.aws_ami.elasticsearch.id
  iam_instance_profile   = data.aws_iam_instance_profile.elastic_search_node.name
  instance_type          = var.instance_type
  key_name               = var.ssh_keyname
  subnet_id              = local.subnet_id
  user_data_base64       = data.template_cloudinit_config.config.rendered
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

  tags = {
    Environment             = var.environment
    HostName                = "${var.service}-${var.environment}-bootstrap.${local.dns_zone_name}"
    ElasticSearchMasterNode = "true"
    Name                    = "${var.service}-${var.environment}-bootstrap"
    Service                 = var.service
  }
}
