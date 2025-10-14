variable "node_disk_size" {
  description = "Size of the disk (in GiB) to use for each node in the node group."
  type        = number
  default     = 20
}

variable "node_instance_types" {
  description = "EC2 instance types for the nodes in the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_ami_type" {
  description = "The AMI type for the nodes in the node group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, and `CUSTOM`."
  type        = string
  default     = "AL2_x86_64"
}

variable "node_desired_size" {
  type        = number
  default     = 1
  description = "Number of worker nodes that should be running in the node group."
}

variable "node_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes that should be running in the node group."
}

variable "node_max_size" {
  type        = number
  default     = 2
  description = "Maximum number of worker nodes that should be running in the node group."
}
