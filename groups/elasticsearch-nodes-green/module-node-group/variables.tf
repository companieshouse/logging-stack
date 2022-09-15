variable "ami_owner_id" {
  description = "The ID of the AMI owner"
  type        = string
}

variable "ami_version_pattern" {
  description = "The pattern with which to match elasticsearch AMIs for instances"
  type        = string
}

variable "availability_zones" {
  type          = list(string)
  description   = "The availability zones into which we'll place instances"
}

variable "box_type" {
  description = "The type of box in terms of the hot/warm/cold architecture. Permitted values being hot|warm|cold|master. Note: master is only added for completeness"
  type        = string
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain log files"
  default     = 1
  type        = number
}

variable "deployment" {
  description   = "The name of the deployment. E.g. blue or green"
  type          = string
}

variable "group_name" {
  description = "The name to apply to this node group (e.g. my-group, cold )"
  type        = string
}

variable "instance_count" {
  description = "The number of instances to provision"
  type        = number
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
}

variable "lvm_block_devices" {
  description = "LVM block devices for nodes"
  type = list(object({
    aws_volume_size_gb: string,
    filesystem_resize_tool: string,
    lvm_logical_volume_device_node: string,
    lvm_physical_volume_device_node: string,
  }))
}

variable "roles" {
  description = "The roles to assign to nodes"
  type        = set(string)
}

variable "root_volume_size" {
  description = "The size of the root volume for nodes in GiB; set this value to 0 to preserve the size specified in the AMI metadata. This value should not be smaller than the size specified in the AMI metadata and used by the root volume snapshot. The filesystem will be expanded automatically to use all available space for the volume and an XFS filesystem is assumed"
  type        = number
}

variable "discovery_availability_zones" {
  description = "A list of availability zones in which to search for master nodes"
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone we're using"
  type        = string
}

variable "elasticsearch_api_target_group_arn" {
  default     = null
  description = "The Elasticsearch API application load balancer target group ARN. Null if no attachment is wanted"
  type        = string
}

variable "elasticsearch_cluster_target_group_arn" {
  default     = null
  description = "The Elasticsearch cluster application load balancer target group ARN. Null if no attachment is wanted"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "instance_type_heap_allocation" {
  default       = {
    "c5.large"  = "2",
    "t3.small"  = "1",
    "t3.medium" = "2",
    "t3.large"  = "4"
    "r5.large"  = "8"
  }
  description = "A map used to determine the Java heap allocation in gigabytes, based on instance type. I.e. 50% of what's available"
  type          = map(string)
}

variable "region" {
  description = "The AWS region in which resources will be administered"
  type        = string
}

variable "role_tags" {
  default = {
    data_cold       = "ElasticSearchColdNode",
    data_content    = "ElasticSearchContentNode",
    data_hot        = "ElasticSearchHotNode",
    data_warm       = "ElasticSearchWarmNode",
    ingest          = "ElasticSearchIngestNode",
    master          = "ElasticSearchMasterNode"
  }
  description = "A map defining what tag should be applied for a given role"
  type = map(string)
}

variable "route53_available" {
  description = "A flag indicating whether Route53 is available"
  type        = bool
}

variable "service" {
  description = "The service name to be used when creating AWS resources"
  type        = string
}

variable "service_group" {
  description = "The Linux group name for association with elasticsearch configuration files"
  type        = string
}

variable "service_user" {
  description = "The Linux username for ownership of elasticsearch configuration files"
  type        = string
}

variable "ssh_cidrs" {
  description = "A list of CIDR blocks to permit remote SSH access from"
  type        = list(string)
}

variable "ssh_keyname" {
  description = "The SSH keypair name to use for remote connectivity"
  type        = string
}

variable "subnet_ids" {
  description = "The ids of the subnets into which we'll place instances"
  type        = list(string)
}

variable "user_data_merge_strategy" {
  description = "Merge strategy to apply to user-data sections for cloud-init"
  type        = string
}

# TODO - Remove me
# This is because the original code didn't specify a merge type for the bootstrap
# commands template. We need to replace the master nodes with nodes in which the
# merge type matches everything else. At that point we can remove this variable
variable "bootstrap_user_data_merge_strategy" {
  description = "Merge strategies to apply to user-data sections for cloud-init"
  type        = string
}







variable "default_ami_version_pattern" {
  description = "The default AMI version pattern to use when matching AMIs"
  type        = string
}

variable "default_instance_type" {
  description = "The default instance type"
  type        = string
}

variable "instance_specifications" {
  type = map(map(map(string)))
}

variable "subnets" {
  description = "A map of subnets keyed by availability zone"
  type = map
}
