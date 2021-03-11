data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}

locals {
  internal_cidrs = values(data.terraform_remote_state.networking.outputs.internal_cidrs)
  placement_subnet_cidrs = [for subnet in data.aws_subnet.placement_subnets : subnet.cidr_block]
  placement_subnet_name_patterns = jsondecode(data.vault_generic_secret.secrets.data["placement_subnet_name_patterns"])
  vpn_cidrs = values(data.terraform_remote_state.networking.outputs.vpn_cidrs)
  vpc_name = data.vault_generic_secret.secrets.data["vpc_name"]

  administration_cidrs = concat(local.internal_cidrs, local.vpn_cidrs)

  elastic_search_http_cidrs = concat(local.administration_cidrs, local.placement_subnet_cidrs)
  prometheus_cidrs = local.administration_cidrs
  ssh_cidrs = local.administration_cidrs
  vpc_id = data.aws_vpc.vpc.id
}
