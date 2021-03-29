resource "aws_acm_certificate" "certificate" {
  domain_name               = "kibana.${var.service}.${var.environment}.${var.dns_zone_name}"
  subject_alternative_names = ["*.kibana.${var.service}.${var.environment}.${var.dns_zone_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_type
  zone_id = var.dns_zone_id
  records = [aws_acm_certificate.certificate.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

resource "aws_lb" "kibana" {
  name                       = "${var.service}-${var.environment}-kibana"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.kibana_load_balancer.id]
  subnets                    = var.placement_subnet_ids
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Service     = var.service
    Name        = "${var.service}-${var.environment}-kibana"
    Type        = "ApplicationLoadBalancer"
  }
}

resource "aws_lb_target_group" "kibana" {
  name        = "${var.environment}-${var.service}-kibana"
  port        = 5601
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/api/status"
    interval            = 60
  }
}

resource "aws_lb_target_group_attachment" "kibana" {
  count            = var.instance_count

  target_group_arn = aws_lb_target_group.kibana.arn
  target_id        = element(aws_instance.kibana.*.private_ip, count.index)
  port             = 5601
}

resource "aws_lb_listener" "kibana" {
  load_balancer_arn = aws_lb.kibana.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.certificate.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana.arn
  }

  depends_on = [
    aws_acm_certificate_validation.certificate
  ]
}

resource "aws_route53_record" "kibana_load_balancer" {
  zone_id = var.dns_zone_id
  name    = "kibana.${var.service}.${var.environment}.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = aws_lb.kibana.dns_name
    zone_id                = aws_lb.kibana.zone_id
    evaluate_target_health = false
  }
}
