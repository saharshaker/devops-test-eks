resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}-node-group-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.private_subnets
  ami_type        = var.node_ami_type
  capacity_type   = "ON_DEMAND"
  disk_size       = var.node_disk_size
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]

    tags = {
      Name = "private-Node-Group-${var.name}"
    }
}
