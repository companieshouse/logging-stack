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
  description = "The pattern with which to match elasticsearch AMIs"
}

variable "data_cold_instance_count" {
  type        = number
  description = "The number of cold data instances to provision"
}

variable "data_cold_instance_type" {
  type        = string
  description = "The instance type to use for cold data nodes"
}

variable "data_cold_lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "LVM block devices for cold data nodes"
}

variable "data_cold_roles" {
  type        = set(string)
  default     = [
    "data_cold",
    "data_content"
  ]
  description = "The roles to assign to cold data nodes"
}

variable "data_cold_root_volume_size" {
  type        = number
  default     = 0
  description = "The size of the root volume for cold data nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "data_hot_instance_count" {
  type        = number
  description = "The number of hot data instances to provision"
}

variable "data_hot_instance_type" {
  type        = string
  description = "The instance type to use for hot data nodes"
}

variable "data_hot_lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "LVM block devices for hot data nodes"
}

variable "data_hot_roles" {
  type        = set(string)
  default     = [
    "data_hot",
    "ingest"
  ]
  description = "The roles to assign to hot data nodes"
}

variable "data_hot_root_volume_size" {
  type        = number
  default     = 0
  description = "The size of the root volume for hot data nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "data_warm_instance_count" {
  type        = number
  description = "The number of warm data instances to provision"
}

variable "data_warm_instance_type" {
  type        = string
  description = "The instance type to use for warm data nodes"
}

variable "data_warm_lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "LVM block devices for warm data nodes"
}

variable "data_warm_roles" {
  type        = set(string)
  default     = [
    "data_warm"
  ]
  description = "The roles to assign to warm data nodes"
}

variable "data_warm_root_volume_size" {
  type        = number
  default     = 0
  description = "The size of the root volume for warm data nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

# Warning: Never go below 3!
variable "master_instance_count" {
  type        = number
  default     = 3
  description = "The number of master instances to provision"
}

variable "master_instance_type" {
  type        = string
  description = "The instance type to use for master nodes"
}

variable "master_lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "LVM block devices for master nodes"
}

variable "master_roles" {
  type        = set(string)
  default     = [
    "master"
  ]
  description = "The roles to assign to master nodes"
}

variable "master_root_volume_size" {
  type        = number
  default     = 0
  description = "The size of the root volume for master nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "repository_name" {
  type        = string
  description = "The name of the repository in which we're operating"
}

variable "service" {
  type        = string
  default     = "logging"
  description = "The service name to be used when creating AWS resources"
}

variable "service_group" {
  type        = string
  default     = "elasticsearch"
  description = "The Linux group name for association with elasticsearch configuration files"
}

variable "service_user" {
  type        = string
  default     = "elasticsearch"
  description = "The Linux username for ownership of elasticsearch configuration files"
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

# ------------------------------------------------------------------------------
# Auto Scaling Group Variables
# ------------------------------------------------------------------------------
variable "scaling_group_configuration" {
  default = {}
  description = "The scaling group configuration indexed by availability zone"
  type = map(map(object({
    ami_version_pattern: string,
    instance_type: string,
    lvm_block_devices: list(object({
      aws_volume_size_gb: string,
      filesystem_resize_tool: string,
      lvm_logical_volume_device_node: string,
      lvm_physical_volume_device_node: string,
    })),
    node_count: number,
    root_volume_size: number
  })))
}
