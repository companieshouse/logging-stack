resource "aws_route53_record" "nodes" {
  for_each = local.instance_definitions

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${each.key}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.nodes[each.key].private_ip]
}
