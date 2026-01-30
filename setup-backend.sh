#!/bin/bash

# Terraform Backend Setup Script
# This script sets up the S3 bucket and DynamoDB table for remote state

set -e

echo "=== Terraform Backend Setup ==="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✓ AWS Account ID: $ACCOUNT_ID"

# Set variables
AWS_REGION="us-east-2"
STATE_BUCKET_NAME="devops-final-terraform-state-${ACCOUNT_ID}"
DYNAMODB_TABLE_NAME="devops-final-terraform-locks"

echo "✓ State Bucket Name: $STATE_BUCKET_NAME"
echo "✓ DynamoDB Table Name: $DYNAMODB_TABLE_NAME"
echo ""

# Step 1: Create backend infrastructure
echo "Step 1: Creating backend infrastructure (S3 bucket and DynamoDB table)..."
cd terraform-backend

# Initialize backend Terraform (uses local state temporarily)
terraform init

# Apply backend configuration
terraform apply -auto-approve

echo "✓ Backend infrastructure created"
echo ""

# Step 2: Migrate main Terraform to use remote state
echo "Step 2: Migrating main Terraform to use remote state..."
cd ../terraform

# Update backend configuration with actual bucket name
sed -i.bak "s/devops-final-terraform-state-ACCOUNT_ID/$STATE_BUCKET_NAME/g" main.tf

# Initialize with S3 backend
echo "Initializing Terraform with S3 backend..."
terraform init

echo "✓ Terraform configured to use remote state"
echo ""

# Display next steps
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Run: terraform plan"
echo "2. Run: terraform apply"
echo ""
echo "Your Terraform state is now stored in:"
echo "  - S3 Bucket: $STATE_BUCKET_NAME"
echo "  - DynamoDB Table: $DYNAMODB_TABLE_NAME"
echo ""
echo "GitHub Actions can now use this remote state for CI/CD deployments."
