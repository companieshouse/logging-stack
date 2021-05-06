provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {}
}

module "kibana" {
  source = "./module-kibana"

  ami_owner_id                  = var.ami_owner_id
  ami_version_pattern           = var.ami_version_pattern
  certificate_arn               = local.certificate_arn
  discovery_availability_zones  = local.discovery_availability_zones
  dns_zone_name                 = local.dns_zone_name
  elastic_search_service_group  = var.elastic_search_service_group
  elastic_search_service_user   = var.elastic_search_service_user
  environment                   = var.environment
  instance_count                = var.instance_count
  instance_type                 = var.instance_type
  instance_profile_name         = data.aws_iam_instance_profile.elastic_search_node.name
  kibana_cidrs                  = local.kibana_cidrs
  kibana_service_group          = var.kibana_service_group
  kibana_service_user           = var.kibana_service_user
  lvm_block_devices             = var.kibana_lvm_block_devices
  placement_subnet_ids          = data.aws_subnet_ids.placement.ids
  region                        = var.region
  roles                         = var.roles
  root_volume_size              = var.root_volume_size
  route53_available             = local.route53_available
  service                       = var.service
  ssh_keyname                   = var.ssh_keyname
  subnet_ids                    = local.placement_subnet_ids_by_availability_zone
  user_data_merge_strategy      = var.user_data_merge_strategy
  vpc_id                        = data.aws_vpc.vpc.id
}
