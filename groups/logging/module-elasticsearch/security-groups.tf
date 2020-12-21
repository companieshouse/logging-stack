resource "aws_security_group" "elasticsearch" {
  name   ="${var.service}-${var.environment}-security-group"
  vpc_id = var.vpc_id

  ingress {
    description = "Inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  ingress {
    description = "Prometheus"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = var.prometheus_cidrs
  }

  ingress {
    description = "Elasticsearch clients"
    from_port   = 9200
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = var.elastic_search_client_cidrs
  }

  ingress {
    description = "Elasticsearch nodes"
    from_port   = 9300
    to_port     = 9400
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
    Name        = "${var.service}-${var.environment}-security-group"
    Environment = var.environment
    Service     = var.service
  }
}
