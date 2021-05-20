resource "aws_acm_certificate" "certificate" {
  count                     = var.route53_available ? 1 : 0

  domain_name               = "${var.service}-${var.environment}-kibana.${var.dns_zone_name}"
  subject_alternative_names = ["*.${var.service}-${var.environment}-kibana.${var.dns_zone_name}"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "certificate" {
  count                   = var.route53_available ? 1 : 0

  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [aws_route53_record.certificate_validation[0].fqdn]
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
  name        = "${var.service}-${var.environment}-kibana"
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
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana.arn
  }

  depends_on = [
    aws_acm_certificate_validation.certificate
  ]
}
