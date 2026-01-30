# RDS DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.app_name}-db"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.database_name
  username = var.database_user
  password = var.database_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  skip_final_snapshot       = var.skip_final_snapshot
  publicly_accessible       = var.publicly_accessible
  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period

  tags = {
    Name = "${var.app_name}-db"
  }
}
