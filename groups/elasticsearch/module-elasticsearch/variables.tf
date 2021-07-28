variable "ami_owner_id" {
  type        = string
  description = "The ID of the AMI owner"
}

variable "ami_version_pattern" {
  type        = string
  description = "The pattern with which to match AMIs"
}

variable "availability_zones" {
  description   = "The availability zones into which we'll place instances"
  type          = list(string)
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
  description = "The roles to assign to cold data nodes"
}

variable "data_cold_root_volume_size" {
  type        = number
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
  description = "The roles to assign to hot data nodes"
}

variable "data_hot_root_volume_size" {
  type        = number
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
  description = "The roles to assign to warm data nodes"
}

variable "data_warm_root_volume_size" {
  type        = number
  description = "The size of the root volume for warm data nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "deployment" {
  description   = "The name of the deployment. E.g. blue or green"
  type          = string
}

variable "discovery_availability_zones" {
  type        = string
  description = "A list of availability zones in which to search for master nodes"
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS zone we're using"
}

variable "elasticsearch_api_target_group_arn" {
  type        = string
  description = "The Elasticsearch API application load balancer target group ARN"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "master_instance_count" {
  type        = number
  description = "The number of master instances to provision. WARNING: This should never go below 3"
}

variable "master_instance_profile_name" {
  type        = string
  description = "The name of the instance profile to associate with the master instances"
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
  description = "The roles to assign to master nodes"
}

variable "master_root_volume_size" {
  type        = number
  description = "The size of the root volume for master nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "instance_type_heap_allocation" {
  type          = map(string)
  default       = {
    "c5.large"  = "2",
    "t3.small"  = "1",
    "t3.medium" = "2",
    "t3.large"  = "4"
    "r5.large"  = "8"
  }
  description = "A map used to determine the Java heap allocation in gigabytes, based on instance type. I.e. 50% of what's available"
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "role_tags" {
  type = map(string)
  default = {
    data_cold       = "ElasticSearchColdNode",
    data_content    = "ElasticSearchContentNode",
    data_hot        = "ElasticSearchHotNode",
    data_warm       = "ElasticSearchWarmNode",
    ingest          = "ElasticSearchIngestNode",
    master          = "ElasticSearchMasterNode"
  }
  description = "A map defining what tag should be applied for a given role"
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
}

variable "service_group" {
  type        = string
  description = "The Linux group name for association with elasticsearch configuration files"
}

variable "service_user" {
  type        = string
  description = "The Linux username for ownership of elasticsearch configuration files"
}

variable "ssh_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks to permit remote SSH access from"
}

variable "ssh_keyname" {
  type        = string
  description = "The SSH keypair name to use for remote connectivity"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ids of the subnets into which we'll place instances"
}

variable "user_data_merge_strategy" {
  type        = string
  description = "Merge strategy to apply to user-data sections for cloud-init"
}
