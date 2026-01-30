terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-final-terraform-state-425210931122"
    key            = "devops-final/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "devops-final-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  app_name              = var.app_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

# Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  app_name = var.app_name
  vpc_id   = module.vpc.vpc_id
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  app_name           = var.app_name
  private_subnet_ids = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  security_group_id  = module.security_groups.rds_security_group_id

  instance_class           = var.rds_instance_class
  allocated_storage        = var.rds_allocated_storage
  database_name            = var.database_name
  database_user            = var.database_user
  database_password        = var.database_password
  skip_final_snapshot      = var.rds_skip_final_snapshot
  publicly_accessible      = var.rds_publicly_accessible
  multi_az                 = var.rds_multi_az
  backup_retention_period  = var.rds_backup_retention_period
}

# ECR Repository
module "ecr" {
  source = "./modules/ecr"

  app_name          = var.app_name
  repository_name   = var.ecr_repository_name
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  app_name           = var.app_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  security_group_id  = module.security_groups.alb_security_group_id
}

# ECS Cluster and Service
module "ecs" {
  source = "./modules/ecs"

  app_name            = var.app_name
  aws_region          = var.aws_region
  container_image     = var.container_image
  private_subnet_ids  = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  security_group_id   = module.security_groups.ecs_tasks_security_group_id
  target_group_arn    = module.alb.target_group_arn

  task_cpu            = var.ecs_task_cpu
  task_memory         = var.ecs_task_memory
  desired_count       = var.ecs_desired_count
  min_capacity        = var.ecs_min_capacity
  max_capacity        = var.ecs_max_capacity

  db_host    = module.rds.rds_address
  db_name    = var.database_name
  db_user    = var.database_user
  db_password = var.database_password
}
