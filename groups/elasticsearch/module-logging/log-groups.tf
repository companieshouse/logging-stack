resource "aws_cloudwatch_log_group" "cold_nodes" {
  name = local.cold_nodes_log_group_name
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    environment = var.environment
    service     = var.service
    Name        = local.cold_nodes_log_group_name
  }
}

resource "aws_cloudwatch_log_group" "hot_nodes" {
  name = local.hot_nodes_log_group_name
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    environment = var.environment
    service     = var.service
    Name        = local.hot_nodes_log_group_name
  }
}

resource "aws_cloudwatch_log_group" "master_nodes" {
  name = local.master_nodes_log_group_name
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    environment = var.environment
    service     = var.service
    Name        = local.master_nodes_log_group_name
  }
}

resource "aws_cloudwatch_log_group" "warm_nodes" {
  name = local.warm_nodes_log_group_name
  retention_in_days = var.cloudwatch_log_retention

  tags = {
    environment = var.environment
    service     = var.service
    Name        = local.warm_nodes_log_group_name
  }
}
