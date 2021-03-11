provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

data "aws_iam_instance_profile" "grafana_node" {
  name = "${var.service}-${var.environment}-grafana"
}

data "aws_route53_zone" "zone" {
  name         = local.dns_zone_name
  private_zone = false
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "development-${var.region}.terraform-state.ch.gov.uk"
    key    = "aws-common-infrastructure-terraform/common-${var.region}/networking.tfstate"
    region = var.region
  }
}

module "grafana" {
  source = "./module-grafana"

  ami_version_pattern           = var.grafana_ami_version_pattern
  discovery_availability_zones  = local.discovery_availability_zones
  dns_zone_id                   = data.aws_route53_zone.zone.zone_id
  dns_zone_name                 = local.dns_zone_name
  environment                   = var.environment
  instance_count                = var.grafana_instance_count
  instance_type                 = var.grafana_instance_type
  instance_profile_name         = data.aws_iam_instance_profile.elastic_search_node.name
  grafana_cidrs                 = local.administration_cidrs
  grafana_service_group         = var.grafana_service_group
  grafana_service_user          = var.grafana_service_user
  lvm_block_devices             = var.grafana_lvm_block_devices
  placement_subnet_ids          = data.aws_subnet_ids.placement.ids
  region                        = var.region
  root_volume_size              = var.grafana_root_volume_size
  service                       = var.service
  ssh_cidrs                     = local.administration_cidrs
  ssh_keyname                   = var.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
  vpc_id                        = data.aws_vpc.vpc.id
}
