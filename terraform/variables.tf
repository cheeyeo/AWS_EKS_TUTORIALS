variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "deploy_old_eks" {
  type = bool
  default = false
  description = "Whether to deploy an older version of EKS 1.27"
}