data "aws_route53_zone" "zone" {
  name         = local.dns_zone_name
  private_zone = false
}

resource "aws_route53_record" "bootstrap" {
  count   = local.dns_zone_id != "" ? 1 : 0

  zone_id = data.aws_route53_zone.zone.zone_id
  name = "${var.service}-${var.environment}-bootstrap.${local.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.bootstrap.private_ip]
}
