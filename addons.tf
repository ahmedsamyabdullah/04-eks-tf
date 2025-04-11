locals {
  eks_addons = {
    vpc_cni       = "v1.10.1-eksbuild.1"
    coredns       = "v1.8.0-eksbuild.1"
    kubeproxy     = "v1.21.5-eksbuild.1"
    prometheus    = "v0.49.0-eksbuild.1"
    appmesh_cni   = "v1.0.1-eksbuild.1"
    metrics_server = "v0.3.7-eksbuild.1"
  }
}
resource "aws_eks_addon" "addons" {
  for_each = local.eks_addons

  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = each.key
  addon_version = each.value

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}