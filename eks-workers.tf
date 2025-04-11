resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn = aws_iam_role.eks_worker_role.arn
  subnet_ids = [ aws_subnet.private.id ]
  scaling_config {
    desired_size = 1 
    min_size = 1 
    max_size = 1 
  }

  capacity_type = "SPOT"
  disk_size = 20         # 20 Gib

  force_update_version = false 
  ami_type       = "AL2_x86_64" 
  instance_types = [ "t3.medium" ]

  labels = {
    role = "eks_worker_role"
  }

  version = "1.29"

  depends_on = [ 
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.eks_worker_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_ec2_container_registry_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.cloudwatch_policy

   ]

   tags = {
     Name = "EKS Node Group"
   }


}