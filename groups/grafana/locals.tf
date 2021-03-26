data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}

locals {
  secrets = data.vault_generic_secret.secrets.data

  discovery_availability_zones = join(",", list("${var.region}a", "${var.region}b", "${var.region}c"))
  dns_zone_name = local.secrets.dns_zone_name
  internal_cidrs = values(data.terraform_remote_state.networking.outputs.internal_cidrs)
  placement_subnet_availability_zones = [for subnet in values(data.aws_subnet.placement) : lookup(subnet, "availability_zone")]
  placement_subnet_name_patterns = jsondecode(local.secrets.placement_subnet_name_patterns)
  vpc_id = data.aws_vpc.vpc.id
  vpc_name = local.secrets.vpc_name
  vpn_cidrs = values(data.terraform_remote_state.networking.outputs.vpn_cidrs)

  administration_cidrs = concat(local.internal_cidrs, local.vpn_cidrs)
  placement_subnet_ids = [for subnet in values(data.aws_subnet.placement) : lookup(subnet, "id")]
  placement_subnet_ids_by_availability_zone = values(zipmap(local.placement_subnet_availability_zones, local.placement_subnet_ids))

  grafana_admin_password          = local.secrets.grafana_admin_password
  ldap_auth_host                  = local.secrets.ldap_auth_host
  ldap_auth_port                  = local.secrets.ldap_auth_port
  ldap_auth_bind_dn               = local.secrets.ldap_auth_bind_dn
  ldap_auth_bind_password         = local.secrets.ldap_auth_bind_password
  ldap_auth_search_filter         = local.secrets.ldap_auth_search_filter
  ldap_auth_search_base_dns       = local.secrets.ldap_auth_search_base_dns
  ldap_grafana_admin_group_dn     = local.secrets.ldap_grafana_admin_group_dn
  ldap_grafana_viewer_group_dn    = local.secrets.ldap_grafana_viewer_group_dn
}
