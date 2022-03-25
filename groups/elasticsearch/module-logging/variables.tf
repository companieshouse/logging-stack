variable "cloudwatch_log_retention" {
  description = "Number of days to retain log files"
  default     = 1
  type        = number
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
}
