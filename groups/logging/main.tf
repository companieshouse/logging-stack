provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

data "aws_iam_instance_profile" "elastic_search_node" {
  name = "${var.service}-${var.environment}-elastic-search"
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

module "elasticsearch" {
  source = "./module-elasticsearch"

  ami_version_pattern           = var.elastic_search_ami_version_pattern

  data_cold_heap_size_gigabytes = local.data_cold_heap_size_gigabytes
  data_cold_instance_count      = var.data_cold_instance_count
  data_cold_instance_type       = var.data_cold_instance_type
  data_cold_lvm_block_devices   = var.data_cold_lvm_block_devices
  data_cold_roles               = var.data_cold_roles
  data_cold_root_volume_size    = var.data_cold_root_volume_size

  data_hot_heap_size_gigabytes = local.data_hot_heap_size_gigabytes
  data_hot_instance_count       = var.data_hot_instance_count
  data_hot_instance_type        = var.data_hot_instance_type
  data_hot_lvm_block_devices    = var.data_hot_lvm_block_devices
  data_hot_roles                = var.data_hot_roles
  data_hot_root_volume_size     = var.data_hot_root_volume_size

  data_warm_heap_size_gigabytes = local.data_warm_heap_size_gigabytes
  data_warm_instance_count      = var.data_warm_instance_count
  data_warm_instance_type       = var.data_warm_instance_type
  data_warm_lvm_block_devices   = var.data_warm_lvm_block_devices
  data_warm_roles               = var.data_warm_roles
  data_warm_root_volume_size    = var.data_warm_root_volume_size

  discovery_availability_zones  = local.discovery_availability_zones
  dns_zone_id                   = data.aws_route53_zone.zone.zone_id
  dns_zone_name                 = local.dns_zone_name
  elastic_search_service_group  = var.elastic_search_service_group
  elastic_search_service_user   = var.elastic_search_service_user
  environment                   = var.environment
  master_instance_count         = var.master_instance_count
  master_instance_profile_name  = data.aws_iam_instance_profile.elastic_search_node.name
  master_instance_type          = var.master_instance_type
  master_roles                  = var.master_roles
  master_root_volume_size       = var.master_root_volume_size
  master_lvm_block_devices      = var.master_lvm_block_devices
  prometheus_cidrs              = local.administration_cidrs
  region                        = var.region
  service                       = var.service
  ssh_cidrs                     = local.administration_cidrs
  ssh_keyname                   = var.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
}

module "kibana" {
  source = "./module-kibana"

  ami_version_pattern           = var.kibana_ami_version_pattern
  discovery_availability_zones  = local.discovery_availability_zones
  dns_zone_id                   = data.aws_route53_zone.zone.zone_id
  dns_zone_name                 = local.dns_zone_name
  elastic_search_service_group  = var.elastic_search_service_group
  elastic_search_service_user   = var.elastic_search_service_user
  environment                   = var.environment
  instance_count                = var.kibana_instance_count
  instance_type                 = var.kibana_instance_type
  instance_profile_name         = data.aws_iam_instance_profile.elastic_search_node.name
  kibana_cidrs                  = local.administration_cidrs
  kibana_service_group          = var.kibana_service_group
  kibana_service_user           = var.kibana_service_user
  lvm_block_devices             = var.kibana_lvm_block_devices
  placement_subnet_ids          = data.aws_subnet_ids.placement.ids
  region                        = var.region
  roles                         = var.kibana_roles
  root_volume_size              = var.kibana_root_volume_size
  service                       = var.service
  ssh_keyname                   = var.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
  vpc_id                        = data.aws_vpc.vpc.id
}
