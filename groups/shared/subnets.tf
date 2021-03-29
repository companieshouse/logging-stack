data "aws_subnet_ids" "placement_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  filter {
    name = "tag:Name"
    values = local.placement_subnet_name_patterns
  }
}

data "aws_subnet" "placement_subnets" {
  for_each = data.aws_subnet_ids.placement_subnets.ids
  id       = each.value
}
