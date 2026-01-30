# IMPORTANT: Customize these values before running terraform apply

aws_region     = "us-west-2"
app_name       = "devops-final"

# VPC Configuration
vpc_cidr              = "10.0.0.0/16"
public_subnet_1_cidr  = "10.0.1.0/24"
public_subnet_2_cidr  = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.10.0/24"
private_subnet_2_cidr = "10.0.11.0/24"

# RDS Configuration
rds_instance_class           = "db.t3.micro"
rds_allocated_storage        = 20
database_name                = "appdb"
database_user                = "admin"
database_password            = "MySecurePassword123456" 
rds_skip_final_snapshot      = true
rds_publicly_accessible      = true
rds_multi_az                 = false
rds_backup_retention_period  = 7

# ECR Configuration
ecr_repository_name = "devops-final"

# ECS Configuration
ecs_task_cpu     = "256"
ecs_task_memory  = "512"
ecs_desired_count = 2
ecs_min_capacity = 1
ecs_max_capacity = 4

# Container Image (will be replaced by GitHub Actions or CLI var)
container_image = ""  # Must be set via -var flag or GitHub Actions
