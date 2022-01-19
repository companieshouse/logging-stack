data "aws_iam_policy_document" "cloudwatch_execution" {
  statement {
    effect    = "Allow"
    sid       = "CloudwatchMetrics"

    actions = [
      "ec2:DescribeTags",
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }

  statement {
  effect    = "Allow"
  sid       = "AllowCloudWatchLogging"

    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.service}-${var.environment}-*:*:*",
    ]
  }
}

data "aws_iam_policy_document" "elastic_search_node_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "discovery_execution" {
  statement {
    effect = "Allow"

    sid = "AllowDescriptionOfEC2Instances"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_instance_profile" "elastic_search_node" {
  name = "${var.service}-${var.environment}-elastic-search"
  role = aws_iam_role.elastic_search_node.name
}

resource "aws_iam_role" "elastic_search_node" {
  name               = "${var.service}-${var.environment}-elastic-search"
  assume_role_policy = data.aws_iam_policy_document.elastic_search_node_trust.json
}

resource "aws_iam_role_policy" "cloudwatch_execution" {
  name   = "cloudwatch_execution"
  role   = aws_iam_role.elastic_search_node.id
  policy = data.aws_iam_policy_document.cloudwatch_execution.json
}

resource "aws_iam_role_policy" "node_discovery" {
  name   = "node_discovery"
  role   = aws_iam_role.elastic_search_node.id
  policy = data.aws_iam_policy_document.discovery_execution.json
}
