data "aws_iam_instance_profile" "elastic_search_node" {
  name = "${var.service}-${var.environment}-elastic-search"
}

data "aws_lb_target_group" "elasticsearch_api" {
  name = "${var.service}-${var.environment}-es-api"
}

data "aws_lb_target_group" "elasticsearch_cluster" {
  name = "${var.service}-${var.environment}-es-cluster"
}

data "aws_route53_zone" "zone" {
  count        = local.route53_available ? 1 : 0

  name         = local.dns_zone_name
  private_zone = false
}

data "aws_subnet_ids" "placement" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name = "tag:Name"
    values = local.placement_subnet_name_patterns
  }
}

data "aws_subnet" "placement" {
  for_each = data.aws_subnet_ids.placement.ids
  id       = each.value
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [local.vpc_name]
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "${var.account_name}-${var.region}.terraform-state.ch.gov.uk"
    key    = "aws-common-infrastructure-terraform/common-${var.region}/networking.tfstate"
    region = var.region
  }
}

data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}
