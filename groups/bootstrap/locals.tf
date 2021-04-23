data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}

locals {
  secrets = data.vault_generic_secret.secrets.data

  ami_root_block_device = tolist(data.aws_ami.elasticsearch.block_device_mappings)[index(data.aws_ami.elasticsearch.block_device_mappings.*.device_name, data.aws_ami.elasticsearch.root_device_name)]
  ami_lvm_block_devices = [
    for block_device in data.aws_ami.elasticsearch.block_device_mappings :
      block_device if block_device.device_name != data.aws_ami.elasticsearch.root_device_name
  ]
  discovery_availability_zones = join(",", list("${var.region}a", "${var.region}b", "${var.region}c"))
  dns_zone_id = data.aws_route53_zone.zone.zone_id
  dns_zone_name = local.secrets["dns_zone_name"]
  heap_size_gigabytes = var.instance_type_heap_allocation[var.instance_type]
  placement_subnet_name_pattern = local.secrets["placement_subnet_name_pattern"]
  subnet_id = tolist(data.aws_subnet_ids.placement.ids)[0]
  vpc_id = data.aws_vpc.vpc.id
  vpc_name = local.secrets["vpc_name"]
}
