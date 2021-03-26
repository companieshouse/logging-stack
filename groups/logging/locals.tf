data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}

locals {
  concourse_worker_cidrs = jsondecode(data.vault_generic_secret.secrets.data["concourse_worker_cidrs"])
  discovery_availability_zones = join(",", list("${var.region}a", "${var.region}b", "${var.region}c"))
  dns_zone_name = data.vault_generic_secret.secrets.data["dns_zone_name"]
  data_cold_heap_size_gigabytes = var.instance_type_heap_allocation[var.data_cold_instance_type]
  data_hot_heap_size_gigabytes = var.instance_type_heap_allocation[var.data_hot_instance_type]
  data_warm_heap_size_gigabytes = var.instance_type_heap_allocation[var.data_warm_instance_type]
  internal_cidrs = values(data.terraform_remote_state.networking.outputs.internal_cidrs)
  placement_subnet_availability_zones = [for subnet in values(data.aws_subnet.placement) : lookup(subnet, "availability_zone")]
  placement_subnet_name_patterns = jsondecode(data.vault_generic_secret.secrets.data["placement_subnet_name_patterns"])
  vpc_id = data.aws_vpc.vpc.id
  vpc_name = data.vault_generic_secret.secrets.data["vpc_name"]
  vpn_cidrs = values(data.terraform_remote_state.networking.outputs.vpn_cidrs)

  administration_cidrs = concat(local.internal_cidrs, local.vpn_cidrs)
  placement_subnet_ids = [for subnet in values(data.aws_subnet.placement) : lookup(subnet, "id")]
  placement_subnet_ids_by_availability_zone = values(zipmap(local.placement_subnet_availability_zones, local.placement_subnet_ids))

  kibana_cidrs = concat(local.administration_cidrs, local.concourse_worker_cidrs)
}
