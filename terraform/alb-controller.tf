locals {
  sa_namespace       = "kube-system"
  sa_name            = "aws-load-balancer-service-account"
  oidc_url_no_scheme = replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")
}
#EKS cluster data
data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

# connect providers
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

#IAM Role for ALB Controller
data "aws_iam_policy_document" "alb_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_no_scheme}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url_no_scheme}:sub"
      values   = ["system:serviceaccount:${local.sa_namespace}:${local.sa_name}"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
}

#IAM Policy for ALB Controller
data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${var.alb_controller_version}/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-lb-controller-policy"
  policy = data.http.alb_policy.response_body
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

#Service Account for ALB Controller
resource "kubernetes_service_account" "alb_service_account" {
  metadata {
    name      = local.sa_name
    namespace = local.sa_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.sa_namespace
  version    = var.helm_chart_alb_controller_version
  cleanup_on_fail = true 
  atomic          = true

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "serviceAccount.name"
      value = local.sa_name
    }
  ]

  depends_on = [
    kubernetes_service_account.alb_service_account,
    aws_iam_role_policy_attachment.alb_attach
  ]
}
