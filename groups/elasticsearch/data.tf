data "aws_route53_zone" "zone" {
  count        = local.route53_available ? 1 : 0

  name         = local.dns_zone_name
  private_zone = false
}
