resource "aws_eks_cluster" "eks_cluster" {
  name = "samy_eks"                               # Should match public and private subnets tags eks_cluster name
  role_arn = aws_iam_role.eks_role.arn
  version = "1.26"
   vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = [ aws_subnet.private.id, aws_subnet.public.id ]
    security_group_ids = [ aws_security_group.eks_sg.id ]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
depends_on = [ 
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
]

  tags = {
    Name = "EKS Cluster"
  }
}

