locals {
  lb_controller_iam_role_name        = "AWLoadbalacer-Controller-${var.eks_cluster_name}" 
  lb_controller_service_account_name = var.eks_lb_sa_name

  set = {
      "clusterName"           = var.eks_cluster_name
      "serviceAccount.create" = var.eks_sa_create
      "serviceAccount.name"   = local.lb_controller_service_account_name
      "region"                = var.eks_region_code 
      "vpcId"                 = var.eks_vpc_id
      "image.repository"      = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"

      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.lb_controller_role.iam_role_arn
  }
}


data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}


module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role = var.eks_lb_controller_role_create

  role_name        = local.lb_controller_iam_role_name
  role_path        = "/"
  role_description = "Used by AWS Load Balancer Controller for EKS"

  role_permissions_boundary_arn = ""

  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:${local.lb_controller_service_account_name}"
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
}

data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.2/docs/install/iam_policy.json"
}

resource "aws_iam_role_policy" "controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  policy      = data.http.iam_policy.body
  role        = module.lb_controller_role.iam_role_name
}


resource "helm_release" "release" {
  provider   = helm.eks_helm
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"
  dynamic "set"{
  for_each = local.set
    content{
      name  = set.key
      value = set.value
    }
  }
}

data "aws_iam_policy_document" "elb_external_dns_policy" {
  count = var.eks_lb_external_policy_enabled ? 1:0
  statement {
    actions = [
     "route53:ChangeResourceRecordSets",
     "route53:ListHostedZones",
     "route53:ListResourceRecordSets"     
    ]
    resources = ["arn:aws:route53:::hostedzone/*", "*"]
    effect = "Allow"
    }
}


resource "aws_iam_policy" "elb_external_dns_policy" {
  count = var.eks_lb_external_policy_enabled ? 1:0
  depends_on  = [helm_release.release]
  name        = "${var.eks_cluster_name}-external-dns-policy"
  path        = "/"
  description = "Policy for the External DNS Policy"

  policy = data.aws_iam_policy_document.elb_external_dns_policy[0].json
}

# Role
data "aws_iam_policy_document" "elb_role_policy" {
  count = var.eks_lb_new_role_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:${var.eks_lb_external_dns_sa_name}",
      ]
    }

    effect = "Allow"
  }
}


resource "aws_iam_role" "elb_external_dns_role" {
  count              = var.eks_lb_new_role_enabled ? 1 : 0
  name               = "${var.eks_cluster_name}-lb-external-role"
  assume_role_policy = data.aws_iam_policy_document.elb_role_policy[0].json
}


#resource "aws_iam_role" "elb_external_dns_role" {
#  count               = var.eks_lb_new_role_enabled ? 1 : 0
#  name                = "${var.eks_cluster_name}-lb-external-role"
#   assume_role_policy = <<EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "Service": "ec2.amazonaws.com"
#         },
#         "Effect": "Allow",
#         "Sid": ""
#       }
#     ]
#   }
#EOF
#}


resource "aws_iam_role_policy_attachment" "elb_external_dns_policy" {
  count      = var.eks_lb_new_role_enabled ? 1:0
  role       = aws_iam_role.elb_external_dns_role[0].name
  policy_arn = var.eks_lb_external_policy_enabled ? aws_iam_policy.elb_external_dns_policy[0].arn : var.eks_lb_policy_arn
}

provider "kubernetes" {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }


resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = var.eks_lb_external_dns_sa_name
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.elb_external_dns_role[0].arn
    }
  }
  automount_service_account_token = true
}
