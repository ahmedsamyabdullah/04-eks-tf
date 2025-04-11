resource "aws_eks_cluster" "eks_cluster" {
  name = "eks"                               # Should match public and private subnets tags eks_cluster name
  role_arn = aws_iam_role.eks_cluster.arn
  version = "1.29"
   vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true
    subnet_ids = [ aws_subnet.private.id, aws_subnet.public.id ]
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]

  tags = {
    Name = "EKS Cluster"
  }
}

