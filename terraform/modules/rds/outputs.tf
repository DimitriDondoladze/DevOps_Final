output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS address (hostname)"
  value       = aws_db_instance.main.address
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "database_user" {
  description = "Database user"
  value       = aws_db_instance.main.username
}
