locals {

  account_ids = data.vault_generic_secret.account_ids.data
  automation_subnets = values(data.aws_subnet.automation)
  logstash_subnets = values(data.aws_subnet.logstash)
  placement_subnets = values(data.aws_subnet.placement)
  placement_vpc_id = data.aws_vpc.placement.id
  secrets = data.vault_generic_secret.secrets.data

  # ----------------------------------------------------------------------------

  certificate_arn = contains(keys(local.secrets), "certificate_arn") ? local.secrets.certificate_arn : null
  dns_zone_name = local.secrets.dns_zone_name

  # TODO - Move secrets once migrated
  migration_values = jsondecode(local.secrets.migration_values)

  automation_subnets_pattern = local.migration_values.automation_subnets_pattern
  automation_vpc_pattern = local.migration_values.automation_vpc_pattern
  logstash_subnets_pattern = local.migration_values.logstash_subnets_pattern
  logstash_vpc_pattern = local.migration_values.logstash_vpc_pattern
  placement_subnets_pattern = local.migration_values.placement_subnets_pattern
  placement_vpc_pattern = local.migration_values.placement_vpc_pattern

  automation_subnet_cidrs = values(zipmap(
    local.automation_subnets.*.availability_zone,
    local.automation_subnets.*.cidr_block
  ))

  logstash_subnet_cidrs = values(zipmap(
    local.logstash_subnets.*.availability_zone,
    local.logstash_subnets.*.cidr_block
  ))

  placement_subnet_ids = values(zipmap(
    local.placement_subnets.*.availability_zone,
    local.placement_subnets.*.id
  ))

  # ----------------------------------------------------------------------------

  # TODO - Use once migrated
  # elastic_search_api_access = {
  #   cidr_blocks: concat(
  #     local.automation_subnet_cidrs
  #   )
  #   list_ids: [
  #     data.aws_ec2_managed_prefix_list.administration.id
  #   ]
  # }

  # Temporary variables used during migration
  concourse_worker_cidrs = jsondecode(local.secrets.concourse_worker_cidrs)
  internal_cidrs = values(data.terraform_remote_state.networking.outputs.internal_cidrs)
  vpn_cidrs = values(data.terraform_remote_state.networking.outputs.vpn_cidrs)

  elastic_search_api_access = {
    cidr_blocks: concat(
      local.concourse_worker_cidrs,
      local.internal_cidrs,
      local.vpn_cidrs
    )
    list_ids: []
  }

  elastic_search_cluster_access = {
    cidr_blocks: concat(
      local.logstash_subnet_cidrs
    )
    list_ids: []
  }

}
