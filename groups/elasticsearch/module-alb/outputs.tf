output "elasticsearch_api_target_group_arn" {
  value = aws_lb_target_group.elasticsearch_api.arn
}
