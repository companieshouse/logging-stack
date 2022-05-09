data "aws_security_group" "elasticsearch" {
  name = "${var.service}-${var.environment}-elasticsearch"
}
