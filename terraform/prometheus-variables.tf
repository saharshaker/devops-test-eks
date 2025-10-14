variable "prometheus_ec2_ami_id" {
  type        = string
  default     = "ami-0a116fa7c861dd5f9"
  description = "ec2 ami type"
}

variable "prometheus_ec2_key_name" {
  type        = string
  default     = "prometheus-server"
  description = "Key pair name to access Prometheus EC2 instance"
}

variable "prometheus_ec2_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for Prometheus server"
}