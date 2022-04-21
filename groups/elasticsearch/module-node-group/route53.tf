resource "aws_route53_record" "nodes" {
  count   = var.route53_available ? var.instance_count : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-${var.deployment}-${var.group_name}-${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [element(aws_instance.nodes.*.private_ip, count.index)]
}
