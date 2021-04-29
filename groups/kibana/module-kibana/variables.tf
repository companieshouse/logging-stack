variable "ami_version_pattern" {
  type        = string
  description = "The pattern with which to match AMIs"
}

variable "certificate_arn" {
  description = "The ARN of the certificate we'll use"
  type        = string
}

variable "discovery_availability_zones" {
  type        = string
  description = "A list of availability zones in which to search for master nodes"
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS zone we're using"
}

variable "elastic_search_service_group" {
  type        = string
  description = "The Linux group name for association with elasticsearch configuration files"
}

variable "elastic_search_service_user" {
  type        = string
  description = "The Linux username for ownership of elasticsearch configuration files"
}

variable "environment" {
  type        = string
  description = "The environment name to be used when creating AWS resources"
}

variable "instance_count" {
  type        = number
  description = "The number of kibana instances to provision"
}

variable "instance_profile_name" {
  type        = string
  description = "The name of the instance profile to associate with the instances"
}

variable "instance_type" {
  type        = string
  description = "The instance type to use"
}

variable "kibana_cidrs" {
  type        = list(string)
  description = "A list of CIDR blocks to permit Kibana access from"
}

variable "kibana_service_group" {
  type        = string
  description = "The Linux group name for association with kibana configuration files"
}

variable "kibana_service_user" {
  type        = string
  description = "The Linux username for ownership of kibana configuration files"
}

variable "lvm_block_devices" {
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
  description = "A list of objects representing LVM block devices; each LVM volume group is assumed to contain a single physical volume and each logical volume is assumed to belong to a single volume group; the filesystem for each logical volume will be expanded to use all available space within the volume group using the filesystem resize tool specified; block device configuration applies only on resource creation"
}

variable "placement_subnet_ids" {
  type = list(string)
  description = "The ids of the subnets into which we'll place kibana instances"
}

variable "roles" {
  type        = set(string)
  description = "The roles to assign to master nodes"
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "root_volume_size" {
  type        = number
  description = "The size of the root volume in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
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

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which to create resources"
}
