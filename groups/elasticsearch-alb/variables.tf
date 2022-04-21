variable "account_name" {
  description = "The name of the AWS account we're using"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "region" {
  description = "The AWS region in which resources will be created"
  type        = string
}

variable "repository_name" {
  default     = "logging-stack"
  description = "The name of the repository in which we're operating"
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

variable "team" {
  default     = "platform"
  description = "The team responsible for administering the instance"
  type        = string
}
