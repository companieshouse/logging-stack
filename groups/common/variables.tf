variable "account_name" {
  type        = string
  description = "The name of the AWS account we're using"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "service" {
  type        = string
  default     = "logging"
  description = "The service name to be used when creating AWS resources"
}

variable "team" {
  type        = string
  description = "The team responsible for administering the instance"
}
