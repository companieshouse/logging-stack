resource "aws_route53_record" "certificate_validation" {
  count   = local.route53_available ? 1 : 0

  zone_id = data.aws_route53_zone.zone[count.index].zone_id
  name    = aws_acm_certificate.certificate[0].domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.certificate[0].domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.certificate[0].domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "elasticsearch_api_load_balancer" {
  count   = local.route53_available ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-elasticsearch-api.${local.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_lb.elasticsearch_api.dns_name
    zone_id                = aws_lb.elasticsearch_api.zone_id
    evaluate_target_health = false
  }
}
