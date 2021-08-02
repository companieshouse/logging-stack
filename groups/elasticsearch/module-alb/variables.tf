variable "certificate_arn" {
  description = "The ARN of the certificate we'll use"
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone we're using"
  type        = string
}

variable "elastic_search_api_cidrs" {
  description = "A list of CIDR blocks to permit ElasticSearch API access from"
  type        = list(string)
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  default     = "logging"
  description = "The service name to be used when creating AWS resources"
  type        = string
}

variable "subnet_ids" {
  description = "The ids of the subnets into which we'll place instances"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID in which to create resources"
  type        = string
}
