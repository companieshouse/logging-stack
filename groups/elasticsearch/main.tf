provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

module "elasticsearch" {
  source = "./module-elasticsearch"

  ami_owner_id                  = var.ami_owner_id
  ami_version_pattern           = var.ami_version_pattern

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
  dns_zone_name                 = local.dns_zone_name
  environment                   = var.environment
  master_instance_count         = var.master_instance_count
  master_instance_profile_name  = data.aws_iam_instance_profile.elastic_search_node.name
  master_instance_type          = var.master_instance_type
  master_roles                  = var.master_roles
  master_root_volume_size       = var.master_root_volume_size
  master_lvm_block_devices      = var.master_lvm_block_devices
  region                        = var.region
  route53_available             = local.route53_available
  service                       = var.service
  service_group                 = var.service_group
  service_user                  = var.service_user
  ssh_cidrs                     = local.administration_cidrs
  ssh_keyname                   = local.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
}
