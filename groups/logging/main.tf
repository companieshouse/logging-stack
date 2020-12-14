provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {
  }
}

module "logging" {
  source = "./module-logging"

  ami_version_pattern = var.ami_version_pattern
  application_subnet  = data.terraform_remote_state.management_vpc.outputs.management_private_subnet_ids["${var.region}a"]
  environment         = var.environment
  instance_hostname   = var.instance_hostname
  instance_type       = var.instance_type
  lvm_block_devices   = var.lvm_block_devices
  region              = var.region
  service             = var.service
  ssh_cidrs           = concat(values(data.terraform_remote_state.management_vpc.outputs.vpn_cidrs), values(data.terraform_remote_state.management_vpc.outputs.internal_cidrs))
  root_volume_size    = var.root_volume_size
  ssh_keyname         = var.ssh_keyname
  vpc_id              = data.terraform_remote_state.management_vpc.outputs.management_vpc_id
}

data "terraform_remote_state" "management_vpc" {
  backend = "s3"
  config = {
    bucket = "development-${var.region}.terraform-state.ch.gov.uk"
    key    = "aws-common-infrastructure-terraform/common-${var.region}/networking.tfstate"
    region = var.region
  }
}

locals {
  application_subnet_cidr_list = [data.terraform_remote_state.management_vpc.outputs.management_private_subnet_cidrs["${var.region}a"]]
}
