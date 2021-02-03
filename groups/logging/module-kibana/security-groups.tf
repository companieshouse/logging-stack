data "aws_security_group" "elasticsearch" {
  name = "${var.service}-${var.environment}-elasticsearch"
}

resource "aws_security_group" "kibana_instances" {
  description = "Restricts access to Kibana ${var.service} instances"
  name = "${var.service}-${var.environment}-kibana-instances"
  vpc_id = var.vpc_id

  ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    security_groups = [aws_security_group.kibana_load_balancer.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-kibana"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}

resource "aws_security_group" "kibana_load_balancer" {
  description = "Restricts access to the Kibana load balancer"
  name = "${var.service}-${var.environment}-kibana-load-balancer"
  vpc_id = var.vpc_id

  ingress {
    description = "Kibana"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.kibana_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-kibana"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}
