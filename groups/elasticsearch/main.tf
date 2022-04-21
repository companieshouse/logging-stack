provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

module "alb" {
  source = "./module-alb"

  certificate_arn           = local.certificate_arn
  dns_zone_name             = local.dns_zone_name
  elastic_search_api_cidrs  = local.elastic_search_api_cidrs
  environment               = var.environment
  route53_available         = local.secrets.route53_available
  service                   = var.service
  subnet_ids                = local.placement_subnet_ids_by_availability_zone
  vpc_id                    = data.aws_vpc.vpc.id
}

module "elasticsearch" {
  for_each = toset(var.deployments)

  source = "./module-elasticsearch"

  ami_owner_id                          = var.ami_owner_id
  availability_zones                    = sort(local.placement_subnet_availability_zones)

  data_cold_ami_version_pattern         = var.data_cold_ami_version_pattern[each.value]
  data_cold_instance_count              = var.data_cold_instance_count[each.value]
  data_cold_instance_type               = var.data_cold_instance_type[each.value]
  data_cold_lvm_block_devices           = var.data_cold_lvm_block_devices[each.value]
  data_cold_roles                       = var.data_cold_roles
  data_cold_root_volume_size            = var.data_cold_root_volume_size[each.value]

  data_hot_ami_version_pattern          = var.data_hot_ami_version_pattern[each.value]
  data_hot_instance_count               = var.data_hot_instance_count[each.value]
  data_hot_instance_type                = var.data_hot_instance_type[each.value]
  data_hot_lvm_block_devices            = var.data_hot_lvm_block_devices[each.value]
  data_hot_roles                        = var.data_hot_roles
  data_hot_root_volume_size             = var.data_hot_root_volume_size[each.value]

  data_warm_ami_version_pattern         = var.data_warm_ami_version_pattern[each.value]
  data_warm_instance_count              = var.data_warm_instance_count[each.value]
  data_warm_instance_type               = var.data_warm_instance_type[each.value]
  data_warm_lvm_block_devices           = var.data_warm_lvm_block_devices[each.value]
  data_warm_roles                       = var.data_warm_roles
  data_warm_root_volume_size            = var.data_warm_root_volume_size[each.value]

  deployment                            = each.value
  discovery_availability_zones          = local.discovery_availability_zones
  dns_zone_name                         = local.dns_zone_name
  elasticsearch_api_target_group_arn    = data.aws_lb_target_group.elasticsearch_api.arn
  environment                           = var.environment
  master_ami_version_pattern            = var.master_ami_version_pattern[each.value]
  master_instance_count                 = var.master_instance_count[each.value]
  master_instance_profile_name          = data.aws_iam_instance_profile.elastic_search_node.name
  master_instance_type                  = var.master_instance_type[each.value]
  master_roles                          = var.master_roles
  master_root_volume_size               = var.master_root_volume_size[each.value]
  master_lvm_block_devices              = var.master_lvm_block_devices[each.value]
  region                                = var.region
  route53_available                     = local.route53_available
  service                               = var.service
  service_group                         = var.service_group
  service_user                          = var.service_user
  ssh_cidrs                             = local.administration_cidrs
  ssh_keyname                           = local.ssh_keyname
  subnet_ids                            = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy              = var.user_data_merge_strategy
}

# ------------------------------------------------------------------------------
# New Modules
# ------------------------------------------------------------------------------
# module "master" {
#   source = "./module-node-group"
#
#   ami_owner_id                        = var.ami_owner_id
#   ami_version_pattern                 = var.NG_master_ami_version_pattern
#   availability_zones                  = sort(local.placement_subnet_availability_zones)
#   box_type                            = "master"
#   deployment                          = "blue"
#   discovery_availability_zones        = local.discovery_availability_zones
#   dns_zone_name                       = local.dns_zone_name
#   environment                         = var.environment
#   group_name                          = "master"
#   instance_count                      = var.NG_master_instance_count
#   instance_type                       = var.NG_master_instance_type
#   lvm_block_devices                   = var.NG_master_lvm_block_devices
#   region                              = var.region
#   roles                               = var.NG_master_roles
#   root_volume_size                    = var.NG_master_root_volume_size
#   route53_available                   = local.route53_available
#   service                             = var.service
#   service_group                       = var.service_group
#   service_user                        = var.service_user
#   ssh_cidrs                           = local.administration_cidrs
#   ssh_keyname                         = local.ssh_keyname
#   subnet_ids                          = local.placement_subnet_ids_by_availability_zone
#   user_data_merge_strategy            = var.user_data_merge_strategy
#   # TODO - Remove me
#   # This is because the original code didn't specify a merge type for the bootstrap
#   # commands template. We need to replace the master nodes with nodes in which the
#   # merge type matches everything else. At that point we can remove this variable
#   bootstrap_user_data_merge_strategy  = null
# }

# module "data_hot" {
#   source = "./module-node-group"
#
#   ami_owner_id                        = var.ami_owner_id
#   ami_version_pattern                 = var.NG_data_hot_ami_version_pattern
#   availability_zones                  = sort(local.placement_subnet_availability_zones)
#   box_type                            = "hot"
#   deployment                          = "blue"
#   discovery_availability_zones        = local.discovery_availability_zones
#   dns_zone_name                       = local.dns_zone_name
#   environment                         = var.environment
#   group_name                          = "data-hot"
#   instance_count                      = var.NG_data_hot_instance_count
#   instance_type                       = var.NG_data_hot_instance_type
#   lvm_block_devices                   = var.NG_data_hot_lvm_block_devices
#   region                              = var.region
#   roles                               = var.NG_data_hot_roles
#   root_volume_size                    = var.NG_data_hot_root_volume_size
#   route53_available                   = local.route53_available
#   service                             = var.service
#   service_group                       = var.service_group
#   service_user                        = var.service_user
#   ssh_cidrs                           = local.administration_cidrs
#   ssh_keyname                         = local.ssh_keyname
#   subnet_ids                          = local.placement_subnet_ids_by_availability_zone
#   user_data_merge_strategy            = var.user_data_merge_strategy
#   # TODO - Remove me
#   # This is because the original code didn't specify a merge type for the bootstrap
#   # commands template. We need to replace the master nodes with nodes in which the
#   # merge type matches everything else. At that point we can remove this variable
#   bootstrap_user_data_merge_strategy  = var.user_data_merge_strategy
# }

# module "data_warm" {
#   source = "./module-node-group"
#
#   ami_owner_id                        = var.ami_owner_id
#   ami_version_pattern                 = var.NG_data_warm_ami_version_pattern
#   availability_zones                  = sort(local.placement_subnet_availability_zones)
#   box_type                            = "warm"
#   deployment                          = "blue"
#   discovery_availability_zones        = local.discovery_availability_zones
#   dns_zone_name                       = local.dns_zone_name
#   environment                         = var.environment
#   group_name                          = "data-warm"
#   instance_count                      = var.NG_data_warm_instance_count
#   instance_type                       = var.NG_data_warm_instance_type
#   lvm_block_devices                   = var.NG_data_warm_lvm_block_devices
#   region                              = var.region
#   roles                               = var.NG_data_warm_roles
#   root_volume_size                    = var.NG_data_warm_root_volume_size
#   route53_available                   = local.route53_available
#   service                             = var.service
#   service_group                       = var.service_group
#   service_user                        = var.service_user
#   ssh_cidrs                           = local.administration_cidrs
#   ssh_keyname                         = local.ssh_keyname
#   subnet_ids                          = local.placement_subnet_ids_by_availability_zone
#   user_data_merge_strategy            = var.user_data_merge_strategy
#   # TODO - Remove me
#   # This is because the original code didn't specify a merge type for the bootstrap
#   # commands template. We need to replace the master nodes with nodes in which the
#   # merge type matches everything else. At that point we can remove this variable
#   bootstrap_user_data_merge_strategy  = var.user_data_merge_strategy
# }

# module "data_cold" {
#   source = "./module-node-group"
#
#   ami_owner_id                        = var.ami_owner_id
#   ami_version_pattern                 = var.NG_data_cold_ami_version_pattern
#   availability_zones                  = sort(local.placement_subnet_availability_zones)
#   box_type                            = "cold"
#   deployment                          = "blue"
#   discovery_availability_zones        = local.discovery_availability_zones
#   dns_zone_name                       = local.dns_zone_name
#   elasticsearch_api_target_group_arn  = data.aws_lb_target_group.elasticsearch_api.arn
#   environment                         = var.environment
#   group_name                          = "data-cold"
#   instance_count                      = var.NG_data_cold_instance_count
#   instance_type                       = var.NG_data_cold_instance_type
#   lvm_block_devices                   = var.NG_data_cold_lvm_block_devices
#   region                              = var.region
#   roles                               = var.NG_data_cold_roles
#   root_volume_size                    = var.NG_data_cold_root_volume_size
#   route53_available                   = local.route53_available
#   service                             = var.service
#   service_group                       = var.service_group
#   service_user                        = var.service_user
#   ssh_cidrs                           = local.administration_cidrs
#   ssh_keyname                         = local.ssh_keyname
#   subnet_ids                          = local.placement_subnet_ids_by_availability_zone
#   user_data_merge_strategy            = var.user_data_merge_strategy
#   # TODO - Remove me
#   # This is because the original code didn't specify a merge type for the bootstrap
#   # commands template. We need to replace the master nodes with nodes in which the
#   # merge type matches everything else. At that point we can remove this variable
#   bootstrap_user_data_merge_strategy  = var.user_data_merge_strategy
# }
