data "aws_security_group" "prometheus" {
  name = "${var.service}-${var.environment}-prometheus"
}

resource "aws_security_group" "elasticsearch" {
  description = "Restricts access for Elastic Search ${var.service} nodes"
  name = "${var.service}-${var.environment}-elasticsearch"
  vpc_id = local.vpc_id

  ingress {
    description = "Inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.ssh_cidrs
  }

  ingress {
    description     = "Prometheus"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [data.aws_security_group.prometheus.id]
  }

  ingress {
    description = "Elasticsearch HTTP"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = local.elastic_search_http_cidrs
  }

  ingress {
    description = "Elasticsearch Transport"
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    self        = "true"
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-elasticsearch"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}
