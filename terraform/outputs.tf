output "cluster_endpoint" {
  value = var.deploy_old_eks == false ? module.eks_new[0].cluster_endpoint : null
}

output "cluster_security_group_id" {
  value = var.deploy_old_eks == false ? module.eks_new[0].cluster_security_group_id : null
}

output "cluster_name" {
  value = var.deploy_old_eks == false ? module.eks_new[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  value = var.deploy_old_eks == true ? module.eks[0].cluster_endpoint : null
}

output "eks_cluster_security_group_id" {
  value = var.deploy_old_eks == true ? module.eks[0].cluster_security_group_id : null
}

output "eks_cluster_name" {
  value = var.deploy_old_eks == true ? module.eks[0].cluster_name : null
}

output "region" {
  value = var.region
}