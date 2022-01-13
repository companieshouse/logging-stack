data "aws_iam_instance_profile" "elastic_search_node" {
  name = "${var.service}-${var.environment}-elastic-search"
}

data "aws_iam_policy_document" "cloudwatch_monitoring" {
  statement {
    effect    = "Allow"
    sid       = "AllowCloudWatchLogging"

    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${module.kibana.log_group_name}:*:*",
    ]
  }

  statement {
    effect    = "Allow"
    sid       = "CloudwatchMetrics"

    actions = [
      "ec2:DescribeTags",
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }
}
