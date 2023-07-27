variable "eks_cluster_name" {
  description = "EKS Cluster Name"
}
variable "eks_k8s_version" {
  description = "EKS K8s Version [ 1.20, 1.21, 1.22, 1.23 ]"
  default     = "1.24"
}
variable "eks_region_code" {
  description = "EKS region code"
  default     = "ap-northeast-2"
}
variable "eks_cluster_encrypte" {
  description = "EKS cluster encrpyte boolean"
  default     = false
} 
variable "eks_account_id" {
  description = "EKS Account ID for Cluster encryption config"
  default   = 883545701064
}
variable "eks_vpc_id" {
  description = "VPC_ID for Cluster"
}
variable "eks_subnet_ids" {
  description = "Any Subnnet ids In VPC_ID" 
}
variable "eks_instance_policy" {
  description = "Policy for SelfManaged NodeGroup" 
}
variable "eks_vpc_cidr_range" {
  description = "Cluster_SG_CIDR_RANGE"
}

#MASTER_NODEGROUP
variable "eks_master_nodegroup_name" {
  description = "Master Nodegourp Name"
}
variable "eks_master_disk_size" {
  description = "Master Mounted Volume Size"
}
variable "eks_master_max_size" {
  description = "Master Node Max Count"
}
variable "eks_master_min_size" {
  description = "Master Node Maintain Minimum Node Count"
}
variable "eks_master_desired_size" {
  description = "Set the desired number of nodes that the group should launch with initially"
}
variable "eks_master_instance_type" {
  description = "Master Node Instance Type"
}
variable "eks_master_capacity_type" {
  description = "Capacity Purchace Option bwtween On-Demand or Spot " 
}
variable "eks_master_sg_group" {
  type        = bool
  description = "Boolean to Create New Node  Security Group"
}

#WORKER_NODEGROUP
variable "eks_worker_nodegroup_name" {
  description = "Worker Nodegourp Name"
}
variable "eks_worker_disk_size" {
  description = "Worker Mounted Volume Size"
}
variable "eks_worker_max_size" {
  description = "Worker Node Max Count"
}
variable "eks_worker_min_size" {
  description = "Worker Node Maintain Minimum Node Count"
}
variable "eks_worker_desired_size" {
  description = "Set the desired number of nodes that the group should launch with initially"
}
variable "eks_worker_instance_type" {
  description = "Worker Node Instance Type"
}
variable "eks_worker_capacity_type" {
  description = "Capacity Purchace Option bwtween On-Demand or Spot " 
}
variable "eks_worker_sg_group" {
  type        = bool
  description = "Boolean to Create New Node  Security Group"
}


#FARGATE
variable "eks_fargate_create" {
  description = "Is Fargate Create bool"
}

#EFS_FILE_SYSTEM
variable "efs_encrypted" {
  description = "test"
}
variable "efs_creation_token" {
  description = "test"
}
variable "efs_lifecycle_policy_to_ia" {
  description = "test"
}
variable "efs_lifecycle_policy_to_primary" {
  description = "test"
}
variable "efs_throughput_mode" {
  description = "test"
}
variable "efs_provisioned_throughput_in_mibps" { 
  description = "test"
}
variable "efs_performance_mode" { 
  description = "test"
}
variable "efs_tag_name" { 
  description = "test"
}

#EFS_BACKUP_POLICY
variable "efs_backup_policy" {
  description = "test"
}

#EFS_SG
variable "efs_nfs_sg_port" {
  description = "test"
}

#EFS_MOUNT_TARGET
variable "efs_mount_public_subnet" {
  description = "test"
}


#EFS_CSI_DRIVER 
variable "efs_csi_enabled" {
  default     = true
  description = "test"
}
variable "efs_mod_dependency" {
  default     = null
  description = "test"
}
variable "efs_new_policy_enabled" {
  description = "test"
}
variable "efs_csi_policy_arn" {
  description = "test"
}
variable "efs_csi_driver_chart_version" {
  default = "2.2.7"
  description = "test"
}
variable "efs_new_role_enabled" {
  description = "test"
}
variable "efs_csi_role_arn" {
  description = "test"
}
variable "efs_service_account_name" {
  default     = "efs-csi-driver-sa"
  description = "test"
}
variable "efs_settings" {
  default = {}
}
variable "efs_create_storageclass" {
  default = true
}
variable "efs_storageclass_name" {
  default = "efs-sc"
}


#ELB
variable "eks_lb_sa_name" {
  description = "test"
}
variable "eks_lb_controller_role_create"{
  default = true
}
variable "eks_sa_create" {
  description = "test"
}
variable "eks_lb_external_dns_sa_name" {
  description = "test"
}
variable "eks_lb_external_policy_enabled" {
  description = "test"
  default     =  true
}
variable "eks_lb_new_role_enabled" {
  description = "test"
  default     =  true
}
variable "eks_lb_policy_arn" {
  description = "test"
  default     =  ""
}


#RDS
variable "eks_rds_identifier" {
  description = "test"
}
variable "eks_rds_engine" {
  description = "test"
}
variable "eks_rds_engine_version" {
  description = "test"
}
variable "eks_rds_engine_instance_class" {
  description = "test"
}
variable "eks_rds_allocate_storage" {
  description = "test"
}
variable "eks_rds_max_allocate_sotrage" {
  description = "test"
}
variable "eks_rds_db_name" {
  description = "test"
}
variable "eks_rds_user_name" {
  description = "test"
}
variable "eks_rds_port" {
  description = "test"
}
variable "eks_subnet_group_create" {
  description = "test"
}
variable "eks_subnet_group_name" {
  description = "test"
}
variable "eks_monitoring_interval" {
  description = "test"
}
variable "eks_create_monitoring_role" {
  description = "test"
}
variable "eks_monitoring_role_name" {
  default = "test-role"
  description = "test"
}
variable "eks_monitoring_role_arn" {
  description = "test"
}
variable "eks_rds_major_engine_version" {
  description = "test"
}

#EKS_OSD
variable "osd_sg_create" {
  default = false
  description = "New Securit Group Create for OSD"
}
variable "osd_domain_name" {
  description = "OSD_domain_name"
}
variable "osd_version" {
  description = "OSD_version 1.3 version means Opensearch"
}
variable "osd_instance_type" {
  description = "OSD_INSTANCE_TYPE"
}
variable "osd_subnet" {
  description = "OSD Subnet is proportional to  AZ Count"
}
variable "osd_create_role" {
  default = false
  description = "OSD Create new Custom Role If It is false AutoCreate"
}
variable "osd_custom_domain_enabled"{
  description = "OSD EBS Enalbled"
}
variable "osd_ebs_enabled" {
  description = "OSD EBS Enalbled"
}
variable "osd_custom_endpoint" {
  description = "OSD EBS Enalbled"
}
variable "osd_ebs_throughput" {
  default     = 250 #250 593
  description = "OSD EBS Thtroughput (MiB/s)"
}
variable "osd_ebs_volume_size" {
  description = "OSD EBS Storage size Per Node"
}
variable "osd_ebs_volume_type" {
  description = "test"
}
variable "osd_master_node_enabled" {
  description = "test"
}
variable "osd_master_node_count" {
  description = "test"
}
variable "osd_master_node_type" {
  description = "test"
}
variable "osd_data_node_count" {
  description = "test"
}
variable "osd_data_node_type" {
  description = "test"
}

#EKS_ECR
variable "ecr_name" {
  description = "ECR NAME"
}
variable "ecr_image_tag_mutability" {
  description = "ECR Image TAG is Mutable or Immutable"
  default     = "MUTABLE"
}
variable "ecr_force_delete" {
  description = "ECR Delete even if Theris is Contain Image"
  default     = true
}
variable "ecr_scan_on_push" {
  description = "ECR Scanning Image after Puhsed"
  default     = false
}

#CodeCommit Repo Name
variable "source_repo_name" {
  description = "Source repo name"
  type        = string
}
