data "aws_route53_zone" "zone" {
  count   = local.route53_available ? 1 : 0

  name         = local.dns_zone_name
  private_zone = false
}

resource "aws_route53_record" "bootstrap" {
  count   = local.route53_available ? 1 : 0

  zone_id = data.aws_route53_zone.zone[count.index].zone_id
  name = "${var.service}-${var.environment}-bootstrap.${local.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.bootstrap.private_ip]
}
