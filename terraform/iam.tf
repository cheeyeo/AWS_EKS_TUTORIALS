data "aws_caller_identity" "current" {}

# NOTE: This IAM role only allows viewing of resources in EKS console in dashboard
# Needs a matching mapRole block in aws-auth configmap with cluster role to allow for the resources to be viewed. If applying eks-console-full-access.yaml it only lets you view the resources; need to create other cluster roles to allow for edit access
data "aws_iam_policy_document" "eks_console_admin_policy" {
  statement {
    effect = "Allow"
    actions = [
      "eks:ListFargateProfiles",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:AccessKubernetesApi",
      "eks:ListAddons",
      "eks:DescribeCluster",
      "eks:DescribeAddonVersions",
      "eks:ListClusters",
      "eks:ListIdentityProviderConfigs",
      "iam:ListRoles"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.id}:parameter/*"
    ]
  }
}

resource "aws_iam_policy" "eks_admin_policy" {
  name        = "EKSAdminPolicy"
  description = "Allow admin access to EKS console"
  policy      = data.aws_iam_policy_document.eks_console_admin_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_console" {
  role       = aws_iam_role.kubernetes_admin.name
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}

resource "aws_iam_role" "kubernetes_admin" {
  name = "KubernetesAdmin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "${data.aws_caller_identity.current.arn}"
        }
    }]
  })
}

output "role_arn" {
  value = aws_iam_role.kubernetes_admin.arn
}
