data "aws_security_group" "elasticsearch" {
  name = "${var.service}-${var.environment}-elasticsearch"
}

resource "aws_security_group" "elasticsearch_api_load_balancer" {
  description = "Restricts access to the ElasticSearch api load balancer"
  name = "${var.service}-${var.environment}-elasticsearch-api-load-balancer"
  vpc_id = var.vpc_id

  ingress {
    description = "Elasticsearch HTTP"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = var.elastic_search_api_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-elasticsearch-api"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}
