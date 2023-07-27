eks_cluster_name = "eks-test"
eks_k8s_version = "1.24"
eks_region_code = "ap-northeast-2"
eks_account_id = "883545701064"
#eks_vpc_id = "${aws_vpc.team01.id}"
eks_vpc_id = "vpc-0a987f929c0e4041d"
#eks_vpc_cidr_range = "10.1.0.0/16"
eks_vpc_cidr_range = "10.10.0.0/16"
#eks_subnet_ids = ["${aws_subnet.team01[count.index]}"]
eks_subnet_ids = [ "subnet-07d74ac8872f0f876", "subnet-0fb51b3d2ece1db05", "subnet-0cdf269ab313752ee", "subnet-051e4cb0f5a61f3a6"]
eks_instance_policy="false"

#MASTER_NODEGROUP 
eks_master_nodegroup_name="aiip-qa-master"
eks_master_disk_size = 300 
eks_master_max_size="2" 
eks_master_min_size="1"
eks_master_desired_size="1"
eks_master_instance_type = "t3.small"
eks_master_capacity_type = "ON_DEMAND"
eks_master_sg_group = false 

#WORKER_NODEGROUP 
eks_worker_nodegroup_name="aiip-qa-worker"
eks_worker_disk_size = 300 
eks_worker_max_size="3"
eks_worker_min_size="2"
eks_worker_desired_size="2"
eks_worker_instance_type = "t3.small"
eks_worker_capacity_type = "ON_DEMAND"
eks_workers_sg_group = false 

#FARGATE
eks_fargate_create = false

#EFS_FILE_SYSTEM
efs_encrypted = true
efs_creation_token = "efs-qa"
efs_lifecycle_policy_to_ia = "AFTER_7_DAYS"  #[AFTER_7_DAYS AFTER_14_DAYS AFTER_30_DAYS AFTER_60_DAYS AFTER_90_DAYS]
efs_lifecycle_policy_to_primary = "AFTER_1_ACCESS"
efs_throughput_mode = "bursting"
efs_provisioned_throughput_in_mibps = 0
efs_performance_mode = "generalPurpose" #[generalPurpose,maxIO]
efs_tag_name = "efs-qa"
eks_worker_sg_group = false 

#EFS_BACKUP_POLICY
efs_backup_policy = "ENABLED"

#EFS_SG
efs_nfs_sg_port = 2049

#EFS_MOUNT_POINT
efs_mount_public_subnet = [ "subnet-07d74ac8872f0f876" , "subnet-051e4cb0f5a61f3a6" ]

#EFS_CSI_DRIVER
efs_sa_name     = "aws-efs-csi-driver"
efs_csi_enabled = true
efs_new_policy_enabled = false
efs_csi_policy_arn = "arn:aws:iam::883545701064:policy/eks-qa-efs-csi-driver"
efs_new_role_enabled   = true
efs_csi_role_arn       = ""

#ELB
eks_lb_sa_name = "aws-load-balancer-controller"
eks_sa_create  = true
eks_lb_controller_role_create = true
eks_lb_external_dns_sa_name   = "external-dns"
eks_lb_external_policy_enabled = true

#RDS
eks_rds_identifier = "rds-qa"
eks_rds_engine     = "mariadb"
eks_rds_engine_version = "10.4.25"
eks_rds_engine_instance_class = "db.t4g.xlarge"
eks_rds_allocate_storage = 50
eks_rds_max_allocate_sotrage = 300
eks_rds_db_name = "accu"
eks_rds_user_name = "root"
eks_rds_port = 3306
eks_subnet_group_create = true
eks_subnet_group_name = "dev-db"
eks_create_monitoring_role = false
eks_monitoring_interval = 0
eks_monitoring_role_arn = "arn:aws:iam::883545701064:role/rds-monitoring-role"
eks_rds_major_engine_version = "10.4"

#OSD
osd_sg_create = false
osd_domain_name = "osd-qa"
osd_version = "7.10" 
# [OpenSearch_1.3, OpenSearch_1.2, OpenSearch_1.1, OpenSearch_1.0, 7.10, 7.9, 7.8, 7.7, 7.4, 7.1, 6.8, 6.7, 6.5, 6.4, 6.3, 6.2, 6.0, 5.6, 5.5, 5.3, 5.1, 2.3, 1.5]
osd_instance_type = "m5.large.elasticsearch"
osd_subnet = ["subnet-0fb51b3d2ece1db05","subnet-0cdf269ab313752ee","subnet-0410f6aa1af3430b8"]
osd_create_role = false
osd_ebs_enabled = true
osd_custom_domain_enabled = true
osd_custom_endpoint = "osd.qa.accuinsight.net"
osd_ebs_volume_size = 500 #Gib
osd_ebs_volume_type = "gp3"
osd_master_node_enabled = true
osd_master_node_count   = 3
osd_master_node_type    = "m6g.large.elasticsearch"
osd_data_node_count     = 3
osd_data_node_type      = "m6g.xlarge.elasticsearch"

#ECR
ecr_name = "eks-qa-ecr"
ecr_image_tag_mutability = "MUTABLE"
ecr_force_delete = true
ecr_scan_on_push = false

#CodeCommit
aws_ecr="test-image"
source_repo_name="test-repo-source"
source_repo_branch="main"
image_repo_name="test-repo-image"