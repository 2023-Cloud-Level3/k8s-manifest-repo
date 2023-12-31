module "iam" {
  source  = "terraform-aws-modules/iam/aws"
  version = "5.3.0"
}


#VPC 생성 
resource "aws_vpc" "eks_vpc" { 
cidr_block = "10.1.0.0/16" 
enable_dns_hostnames = true
enable_dns_support = true
instance_tenancy = "default"
tags = {
Name = "team01-vpc"
} 
}
output "vpc_id" {
  description = "VPC의 ID"
  value       = aws_vpc.eks_vpc.id
}

#Subnet 생성 
resource "aws_subnet" "eks_subnet" {
  count             = 6
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.1.${count.index + 1}.0/24"  # 서브넷의 CIDR 블록을 "10.1.1.0/24"부터 "10.1.6.0/24"까지 순차적으로 설정합니다.
  availability_zone = element(["ap-northeast-2a", "ap-northeast-2b"], count.index % 2)  # 서브넷을 가용 영역 "ap-northeast-2a"와 "ap-northeast-2b"로 번갈아가면서 생성합니다.

  tags = {
    Name = "aws_subnet.eks_subnet[*].id"
  }
}

output "subnet_ids" {
  description = "생성된 서브넷들의 ID 리스트"
  value       = aws_subnet.eks_subnet[*].id
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_k8s_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cloudwatch_log_group     = false

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }


  
  cluster_security_group_additional_rules = {
      ingress_self_all = {
        description = "Cluster to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks      = ["0.0.0.0/0"]
      }
      egress_all = {
        description      = "cluster all egress"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        type             = "egress"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    }

  node_security_group_additional_rules = {
      ingress_self_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks      = ["0.0.0.0/0"]
      }
      egress_all = {
        description      = "Node all egress"
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        type             = "egress"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
      }
    }

  cluster_encryption_config = var.eks_cluster_encrypte ? [{
    provider_key_arn = "arn:aws:kms:${ var.eks_region_code }:${ var.eks_account_id }:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    resources        = ["secrets"]
  }] : []
  
  vpc_id = aws_vpc.eks_vpc.id
  #vpc_id     = "${aws_vpc.team01.id}"
  #subnet_ids = var.eks_subnet_ids
  #subnet_ids = "${aws_subnet.team01[count.index]}"
  subnet_ids = aws_subnet.eks_subnet[*].id


 eks_managed_node_group_defaults = {
    disk_size      = var.eks_master_disk_size #Gib
    instance_types = ["t3.small","m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {

   "${var.eks_master_nodegroup_name}" = {
      min_size     = var.eks_master_min_size
      max_size     = var.eks_master_max_size
      desired_size = var.eks_master_desired_size

      instance_types = [var.eks_master_instance_type]
      capacity_type  = var.eks_master_capacity_type
      security_group_description = "Node group ${var.eks_master_nodegroup_name} SG"
      create_security_group = var.eks_master_sg_group
      disk_size     = var.eks_master_disk_size
    }

   "${ var.eks_worker_nodegroup_name}" = {
      min_size     = var.eks_worker_min_size
      max_size     = var.eks_worker_max_size
      desired_size = var.eks_worker_desired_size
      
      instance_types = [var.eks_worker_instance_type]
      capacity_type  = var.eks_worker_capacity_type
      security_group_description = "Node group ${var.eks_worker_nodegroup_name} SG"
      create_security_group = var.eks_worker_sg_group
      disk_size     = var.eks_worker_disk_size
    }

    master  = {
      min_size     = var.eks_master_min_size
      max_size     = var.eks_master_max_size
      desired_size = var.eks_master_desired_size

      instance_types = [var.eks_master_instance_type]
      capacity_type  = var.eks_master_capacity_type
      security_group_description = "Node group ${var.eks_master_nodegroup_name} SG"
      create_security_group = var.eks_master_sg_group
      disk_size     = var.eks_master_disk_size
    }
  }
  


 # Fargate Profile(s)
  fargate_profiles = {
    default = {
      create = false
      name = "default"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "backend"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
 }
}

provider "helm" {
  alias     = "eks_helm"
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

