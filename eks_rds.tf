module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = var.eks_rds_identifier #name for DB instance

  engine            = var.eks_rds_engine #mysql,mariadb,postgres,oricle
  engine_version    = var.eks_rds_engine_version 
  instance_class    = var.eks_rds_engine_instance_class
  allocated_storage = var.eks_rds_allocate_storage      #Minimum: 20 GiB. Maximum: 65,536 GiB
  max_allocated_storage = var.eks_rds_max_allocate_sotrage  # 0 Not AutoScaling

  db_name  = var.eks_rds_db_name #Initial DB name ( default / postgres / ORCL )B
  username = var.eks_rds_user_name 
  port     = var.eks_rds_port 


  iam_database_authentication_enabled = false 

  vpc_security_group_ids = ["${module.eks.cluster_primary_security_group_id}", "${module.eks.node_security_group_id}"] # Cluster & Nodeshare

   # Enable creation of subnet group (disabled by default)
  create_db_subnet_group = var.eks_subnet_group_create
  db_subnet_group_name = var.eks_subnet_group_name
  # Enable creation of monitoring IAM role
  create_monitoring_role = var.eks_create_monitoring_role

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = var.eks_monitoring_interval # 0, 1, 5, 10, 15, 30, 60 0=No Enhanced Monitoring role
  monitoring_role_name = "rds-${var.eks_cluster_name}-monitoring-role"#new create role 
  monitoring_role_arn =  var.eks_monitoring_role_arn

  maintenance_window = "Mon:00:00-Mon:03:00" # AWS Managed RDS Period 
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids             = var.eks_subnet_ids

  # DB parameter group
  family = ""

  # DB option group
  major_engine_version = var.eks_rds_major_engine_version #Required
  skip_final_snapshot  = true

  # Database Deletion Protection
  deletion_protection = false
  create_db_parameter_group = false

 # parameters = [
 #   {
 #     name = "character_set_client"
 #     value = "utf8mb4"
 #   },
 #   {
 #     name = "character_set_server"
 #     value = "utf8mb4"
 #   }
 # ]

 # options = [
 #   {
 #     option_name = "MARIADB_AUDIT_PLUGIN"
 #
 #     option_settings = [
 #       {
 #         name  = "SERVER_AUDIT_EVENTS"
 #         value = "CONNECT"
 #       },
 #       {
 #         name  = "SERVER_AUDIT_FILE_ROTATIONS"
 #         value = "37"
 #       },
 #     ]
 #   },
 # ]
}
