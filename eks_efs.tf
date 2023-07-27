resource "aws_efs_file_system" "efs" {
  encrypted = var.efs_encrypted
  creation_token = var.efs_creation_token
  lifecycle_policy {
    transition_to_ia = var.efs_lifecycle_policy_to_ia
  }
  lifecycle_policy {
    transition_to_primary_storage_class = var.efs_lifecycle_policy_to_primary
  }
  throughput_mode = var.efs_throughput_mode #provisioned,burstring
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps #It is required value when provisioned is set to provisioned 
  performance_mode = var.efs_performance_mode #generalPurpos,maxIO,
  tags = {
    Name = var.efs_tag_name
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = var.efs_backup_policy
  }
}


resource "aws_efs_mount_target" "efs-mount" {
   count = length(var.efs_mount_public_subnet)
   file_system_id  = "${aws_efs_file_system.efs.id}"
   subnet_id = element(var.efs_mount_public_subnet, count.index)
   security_groups = ["${aws_security_group.efs-sg.id}"]

}


#EFS_CSI_ROLE
data "aws_iam_policy_document" "efs_csi_driver" {
  count = var.efs_csi_enabled ? 1 : 0

  statement {
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "elasticfilesystem:CreateAccessPoint"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    actions = [
      "elasticfilesystem:DeleteAccessPoint"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}


resource "aws_iam_policy" "efs_csi_driver" {
  depends_on  = [var.efs_mod_dependency]
  count       = var.efs_new_policy_enabled ? 1 : 0
  name        = "${var.eks_cluster_name}-efs-csi-driver"
  path        = "/"
  description = "Policy for the EFS CSI driver"

  policy = data.aws_iam_policy_document.efs_csi_driver[0].json
}

# Role
data "aws_iam_policy_document" "efs_csi_driver_assume" {
  count = var.efs_csi_enabled ? 1 : 0

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
        "system:serviceaccount:kube-system:${var.efs_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "efs_csi_driver" {
  count              = var.efs_new_role_enabled ? 1 : 0
  name               = "${var.eks_cluster_name}-efs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_assume[0].json
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count      = var.efs_new_role_enabled ? 1 : 0
  role       = aws_iam_role.efs_csi_driver[0].name
  policy_arn = var.efs_new_policy_enabled ? aws_iam_policy.efs_csi_driver[0].arn : var.efs_csi_policy_arn
}

#EFS_CSI_HELM_RELEASE
resource "helm_release" "kubernetes_efs_csi_driver" {
  provider   = helm.eks_helm
  count      = var.efs_csi_enabled ? 1 : 0
  name       = "aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  version    = var.efs_csi_driver_chart_version
  namespace  = "kube-system"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = var.efs_service_account_name
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.efs_new_role_enabled ? aws_iam_role.efs_csi_driver[0].arn : var.efs_csi_role_arn
  }

  set {
    name = "node.serviceAccount.create"
    # We're using the same service account for both the nodes and controllers,
    # and we're already creating the service account in the controller config
    # above.
    value = "false"
  }

  set {
    name  = "node.serviceAccount.name"
    value = var.efs_service_account_name
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.efs_new_role_enabled ? aws_iam_role.efs_csi_driver[0].arn : var.efs_csi_role_arn
  }

  values = [
    yamlencode(var.efs_settings)
  ]
}

provider "kubectl"{
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

resource "kubectl_manifest" "storage_class" {
  count      = (var.efs_csi_enabled && var.efs_create_storageclass) ? 1 : 0
  yaml_body  = <<YAML
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.efs.id}
  directoryPerms: "700"
  gidRangeStart: "1000" # optional
  gidRangeEnd: "2000" # optional
  basePath: "/dynamic_provisioning" # optional
YAML
  depends_on = [helm_release.kubernetes_efs_csi_driver]
}

