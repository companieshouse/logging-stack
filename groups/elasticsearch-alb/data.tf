data "aws_ec2_managed_prefix_list" "administration" {
  name = "administration-cidr-ranges"
}

data "aws_route53_zone" "zone" {
  count        = var.route53_available ? 1 : 0

  name         = local.dns_zone_name
  private_zone = false
}

data "aws_security_group" "elasticsearch" {
  name = "${var.service}-${var.environment}-elasticsearch"
}

data "aws_subnet" "automation" {
  provider = aws.development_eu_west_1

  for_each = data.aws_subnet_ids.automation.ids

  id = each.value
}

data "aws_subnet" "logstash" {
  for_each = data.aws_subnet_ids.logstash.ids
  id       = each.value
}

data "aws_subnet" "placement" {
  for_each = data.aws_subnet_ids.placement.ids
  id       = each.value
}

data "aws_subnet_ids" "automation" {
  provider = aws.development_eu_west_1

  vpc_id = data.aws_vpc.automation.id

  filter {
    name   = "tag:Name"
    values = [local.automation_subnets_pattern]
  }
}

data "aws_subnet_ids" "logstash" {
  vpc_id = data.aws_vpc.logstash.id

  filter {
    name = "tag:Name"
    values = [local.logstash_subnets_pattern]
  }
}

data "aws_subnet_ids" "placement" {
  vpc_id = data.aws_vpc.placement.id

  filter {
    name = "tag:Name"
    values = [local.placement_subnets_pattern]
  }
}

data "aws_vpc" "automation" {
  provider = aws.development_eu_west_1

  filter {
    name   = "tag:Name"
    values = [local.automation_vpc_pattern]
  }
}

data "aws_vpc" "logstash" {
  filter {
    name   = "tag:Name"
    values = [local.logstash_vpc_pattern]
  }
}

data "aws_vpc" "placement" {
  filter {
    name   = "tag:Name"
    values = [local.placement_vpc_pattern]
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

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.repository_name}"
}
