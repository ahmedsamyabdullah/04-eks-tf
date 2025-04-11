resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

locals {
  eks_addons = {
    "coredns"              = "v1.10.1-eksbuild.1"
    "kube-proxy"           = "v1.30.1-eksbuild.1"
    "vpc-cni"              = "v1.16.2-eksbuild.1"
    "aws-ebs-csi-driver"   = "v1.27.0-eksbuild.1"
    "aws-efs-csi-driver"   = "v1.7.0-eksbuild.1"
  }
}
resource "aws_eks_addon" "addons" {
  for_each = local.eks_addons

  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name = each.key
  addon_version = each.value
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "aws_eks_cluster" "eks_cluster" {
  name = "eks"                               # Should match public and private subnets tags eks_cluster name
  role_arn = aws_iam_role.eks_cluster.arn
  version = "1.29"  # optional
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]

  tags = {
    Name = "EKS Cluster"
  }
}

