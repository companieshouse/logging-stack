resource "aws_security_group" "logging" {
  name   ="${var.service}-${var.environment}-security-group"
  vpc_id = var.vpc_id

  ingress {
    description = "Inbound SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
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
