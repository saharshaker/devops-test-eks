variable "alb_controller_version" {
  description = "The version of the AWS Load Balancer Controller to deploy"
  type        = string
  default     = "2.14.0"
}

variable "aws_region" {
  description = "The AWS region where the resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "helm_chart_alb_controller_version" {
  description = "The version of the Helm chart for AWS Load Balancer Controller"
  type        = string
  default     = "1.14.0"
}

variable "service_account_namespace" {
  type        = string
  default     = "kube-system"
  description = "namespace for the service account"
}