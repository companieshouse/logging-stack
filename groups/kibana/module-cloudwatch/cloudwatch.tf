resource "aws_cloudwatch_dashboard" "concourse" {
  dashboard_name = "${var.service}-${var.environment}-kibana"

  dashboard_body = templatefile("${path.module}/dashboard.tmpl", {
    environment = var.environment
    region      = var.region
    service     = var.service
  })
}
