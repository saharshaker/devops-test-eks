variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "values for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true

}

variable "vpc_enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = true

}

###
variable "enable_dns_support" {
  description = "Enable DNS support for VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Assign public IP on instance launch"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the VPC"
  type        = string
}