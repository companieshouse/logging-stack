resource "aws_cloudwatch_log_group" "nodes" {
  name = local.log_group_name
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    environment = var.environment
    service     = var.service
    Name        = local.log_group_name
  }
}
