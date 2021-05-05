variable "account_name" {
  type        = string
  description = "The name of the AWS account we're using"
}

variable "ami_owner_id" {
  type        = string
  description = "The ID of the AMI owner"
}

variable "ami_version_pattern" {
  type        = string
  default     = "\\d.\\d.\\d"
  description = "The pattern with which to match kibana AMIs"
}

variable "elastic_search_service_group" {
  type        = string
  default     = "elasticsearch"
  description = "The Linux group name for association with elasticsearch configuration files"
}

variable "elastic_search_service_user" {
  type        = string
  default     = "elasticsearch"
  description = "The Linux username for ownership of elasticsearch configuration files"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "The number of kibana instances to provision"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "The instance type to use for kibana instances"
}

variable "kibana_lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "LVM block devices for kibana nodes"
}

variable "kibana_service_group" {
  type        = string
  default     = "kibana"
  description = "The Linux group name for association with kibana configuration files"
}

variable "kibana_service_user" {
  type        = string
  default     = "kibana"
  description = "The Linux username for ownership of kibana configuration files"
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "repository_name" {
  type        = string
  description = "The name of the repository in which we're operating"
}

variable "roles" {
  type        = set(string)
  default     = []
  description = "The roles to assign to kibana nodes"
}

variable "root_volume_size" {
  type        = number
  default     = 0
  description = "The size of the root volume for kibana instances in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "service" {
  type        = string
  default     = "logging"
  description = "The service name to be used when creating AWS resources"
}

variable "ssh_keyname" {
  type        = string
  description = "The SSH keypair name to use for remote connectivity"
}

variable "team" {
  type        = string
  description = "The team responsible for administering the instance"
}

variable "user_data_merge_strategy" {
  type        = string
  default     = "list(append)+dict(recurse_array)+str()"
  description = "Merge strategy to apply to user-data sections for cloud-init"
}
