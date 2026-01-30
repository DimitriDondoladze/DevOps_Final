variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  # Must be globally unique across all AWS accounts
  default     = "devops-final-terraform-state-425210931122"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "devops-final-terraform-locks"
}

data "aws_caller_identity" "current" {}
