variable "certificate_arn" {
  description = "The ARN of the certificate we'll use"
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone we're using"
  type        = string
}

variable "elastic_search_api_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks to permit ElasticSearch API access from"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  type        = string
  default     = "logging"
  description = "The service name to be used when creating AWS resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ids of the subnets into which we'll place instances"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which to create resources"
}
