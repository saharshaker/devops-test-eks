output "node_group_private_id" {
  description = "private Node Group ID"
  value       = aws_eks_node_group.eks_ng_private.id
}

output "node_group_private_arn" {
  description = "private Node Group ARN"
  value       = aws_eks_node_group.eks_ng_private.arn
}


output "node_group_private_status" {
  description = "private Node Group status"
  value       = aws_eks_node_group.eks_ng_private.status
}

output "node_group_private_version" {
  description = "private Node Group Kubernetes Version"
  value       = aws_eks_node_group.eks_ng_private.version
}