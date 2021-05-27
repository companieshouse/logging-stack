data "aws_iam_policy_document" "elastic_search_discovery_trust" {
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

data "aws_iam_policy_document" "elastic_search_discovery_execution" {
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
  role = aws_iam_role.elastic_search_discovery_execution.name
}

resource "aws_iam_role" "elastic_search_discovery_execution" {
  name               = "${var.service}-${var.environment}-elastic-search"
  assume_role_policy = data.aws_iam_policy_document.elastic_search_discovery_trust.json
}

resource "aws_iam_role_policy" "elastic_search_discovery_execution" {
  name   = "${var.service}-${var.environment}-elastic-search"
  role   = aws_iam_role.elastic_search_discovery_execution.id
  policy = data.aws_iam_policy_document.elastic_search_discovery_execution.json
}
