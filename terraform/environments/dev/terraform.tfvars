# Environment-specific config: DEV

name = "adcash-dev"

tags = {
  Environment = "dev"
  Terraform   = "true"
  Project     = "adcash-dev"
}

# VPC CIDR
vpc_cidr_block = "10.0.0.0/16"

# Public subnets
vpc_public_subnets = [
  "10.0.101.0/24", 
  "10.0.102.0/24"
]

# private subnets
vpc_private_subnets = [
    "10.0.1.0/24", 
    "10.0.2.0/24"
]

# NAT / VPN
vpc_enable_nat_gateway = true
vpc_enable_vpn_gateway = false

# DNS
enable_dns_hostnames   = true
enable_dns_support     = true
map_public_ip_on_launch = true

# EKS Cluster
cluster_version                      = "1.34"
cluster_service_ipv4_cidr            = "172.20.0.0/16"
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

# EKS Node Group
node_disk_size    = 20
node_instance_types = ["t3.medium"]
node_ami_type     = "AL2023_x86_64_STANDARD"
node_desired_size = 1
node_min_size     = 1
node_max_size     = 1

## LB Controller
alb_controller_version = "v2.14.0"
aws_region = "eu-central-1"

## Prometheus EC2
prometheus_ec2_ami_id = "ami-0a116fa7c861dd5f9"
prometheus_ec2_key_name = "prometheus-server"
prometheus_ec2_instance_type = "t3.micro"

helm_chart_alb_controller_version = "1.14.0"