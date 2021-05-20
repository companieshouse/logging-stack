data "aws_route53_zone" "zone" {
  count        = var.route53_available ? 1 : 0

  name         = var.dns_zone_name
  private_zone = false
}

resource "aws_route53_record" "master" {
  count   = var.route53_available ? "${var.master_instance_count}" : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-master-${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.master.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "data_cold" {
  count   = var.route53_available ? "${var.data_cold_instance_count}" : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-data-cold-${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.data_cold.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "data_hot" {
  count   = var.route53_available ? "${var.data_hot_instance_count}" : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-data-hot-${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.data_hot.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "data_warm" {
  count   = var.route53_available ? "${var.data_warm_instance_count}" : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-data-warm-${count.index + 1}.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.data_warm.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "ingest" {
  count   = var.route53_available ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "${var.service}-${var.environment}-sniffing.${var.dns_zone_name}"
  type    = "A"
  ttl     = "300"
  records = aws_instance.data_hot.*.private_ip
}
