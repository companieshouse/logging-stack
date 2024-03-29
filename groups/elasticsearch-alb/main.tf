terraform {
  required_version = ">= 0.13.0, < 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0, < 4.0"
    }
  }
  backend "s3" {}
}

resource "aws_acm_certificate" "certificate" {
  count                     = var.route53_available ? 1 : 0

  domain_name               = "${var.service}-${var.environment}-elasticsearch-api.${local.dns_zone_name}"
  subject_alternative_names = ["*.${var.service}-${var.environment}-elasticsearch-api.${local.dns_zone_name}"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "certificate" {
  count                   = var.route53_available ? 1 : 0

  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [aws_route53_record.certificate_validation[0].fqdn]
}

resource "aws_lb" "elasticsearch_api" {
  name                       = "${var.service}-${var.environment}-es-api"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.elasticsearch_api_load_balancer.id]
  subnets                    = local.placement_subnet_ids
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Service     = var.service
    Name        = "${var.service}-${var.environment}-elasticsearch-api"
    Type        = "ApplicationLoadBalancer"
  }
}

resource "aws_lb" "elasticsearch_cluster" {
  name                       = "${var.service}-${var.environment}-es-cluster"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.elasticsearch_cluster_load_balancer.id]
  subnets                    = local.placement_subnet_ids
  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Service     = var.service
    Name        = "${var.service}-${var.environment}-elasticsearch-cluster"
    Type        = "ApplicationLoadBalancer"
  }
}

resource "aws_lb_target_group" "elasticsearch_api" {
  name        = "${var.service}-${var.environment}-es-api"
  port        = 9200
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.placement_vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/_cat/health"
    interval            = 60
  }
}

resource "aws_lb_target_group" "elasticsearch_cluster" {
  name        = "${var.service}-${var.environment}-es-cluster"
  port        = 9200
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.placement_vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/_cat/health"
    interval            = 60
  }
}

resource "aws_lb_listener" "elasticsearch_api" {
  load_balancer_arn = aws_lb.elasticsearch_api.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.route53_available ? aws_acm_certificate_validation.certificate[0].certificate_arn : local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elasticsearch_api.arn
  }
}

resource "aws_lb_listener" "elasticsearch_cluster" {
  load_balancer_arn = aws_lb.elasticsearch_cluster.arn
  port              = 9200
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elasticsearch_cluster.arn
  }
}
