resource "aws_security_group" "elasticsearch_api_load_balancer" {
  description = "Restricts access to the ElasticSearch api load balancer"
  name = "${var.service}-${var.environment}-elasticsearch-api-load-balancer"
  vpc_id = local.placement_vpc_id

  ingress {
    description     = "Elasticsearch HTTP"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = local.elastic_search_api_access.cidr_blocks
    prefix_list_ids = local.elastic_search_api_access.list_ids
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-elasticsearch-api"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}

resource "aws_security_group" "elasticsearch_cluster_load_balancer" {
  description = "Restricts access to the ElasticSearch cluster load balancer"
  name = "${var.service}-${var.environment}-elasticsearch-cluster-load-balancer"
  vpc_id = local.placement_vpc_id

  ingress {
    description     = "Elasticsearch HTTP"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    cidr_blocks     = local.elastic_search_cluster_access.cidr_blocks
    prefix_list_ids = local.elastic_search_cluster_access.list_ids
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service}-${var.environment}-elasticsearch-cluster"
    Environment = var.environment
    Service     = var.service
    Type        = "SecurityGroup"
  }
}
