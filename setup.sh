#!/bin/bash

# DevOps Final Project - Setup Script
# This script automates local setup and deployment

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   DevOps Final Project - AWS Deployment Setup              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}[1/5]${NC} Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}⚠ Terraform not found. Install from: https://www.terraform.io/downloads${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Terraform: $(terraform version -json | jq -r '.terraform_version')"

if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}⚠ AWS CLI not found. Install from: https://aws.amazon.com/cli${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} AWS CLI: $(aws --version | cut -d' ' -f1)"

if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠ Git not found. Install from: https://git-scm.com${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Git: $(git --version | cut -d' ' -f3)"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠ Docker not found. Install from: https://docker.com${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker: $(docker --version | cut -d' ' -f3)"

echo ""

# Verify AWS credentials
echo -e "${BLUE}[2/5]${NC} Verifying AWS credentials..."

if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${YELLOW}⚠ AWS credentials not configured. Run: aws configure${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
echo -e "${GREEN}✓${NC} AWS Account: $ACCOUNT_ID"
echo -e "${GREEN}✓${NC} User: $USER_ARN"

echo ""

# Check and edit terraform.tfvars
echo -e "${BLUE}[3/5]${NC} Checking Terraform configuration..."

if [ ! -f "terraform/terraform.tfvars" ]; then
    echo -e "${YELLOW}✗ terraform/terraform.tfvars not found${NC}"
    exit 1
fi

# Check if database password is still default
if grep -q 'database_password = "ChangeMe@12345"' terraform/terraform.tfvars; then
    echo -e "${YELLOW}⚠ WARNING: Using default database password!${NC}"
    echo -e "${YELLOW}  Edit terraform/terraform.tfvars and change database_password${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Configuration file found"

echo ""

# Initialize Terraform
echo -e "${BLUE}[4/5]${NC} Initializing Terraform..."

cd terraform

terraform init
terraform validate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Terraform initialized and validated"
else
    echo -e "${YELLOW}✗ Terraform validation failed${NC}"
    exit 1
fi

terraform fmt -recursive
echo -e "${GREEN}✓${NC} Terraform files formatted"

cd ..

echo ""

# Show Terraform plan
echo -e "${BLUE}[5/5]${NC} Generating deployment plan..."

cd terraform

terraform plan -out=tfplan

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  Setup Complete!                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo ""
echo "1. Review the terraform plan above"
echo "2. Deploy infrastructure:"
echo "   terraform apply tfplan"
echo ""
echo "3. After deployment, get outputs:"
echo "   terraform output"
echo ""
echo "4. Access your application:"
echo "   http://<ALB_DNS_NAME>"
echo ""
echo "5. To clean up resources:"
echo "   terraform destroy"
echo ""
echo -e "${YELLOW}⚠ Remember to destroy resources to avoid AWS charges!${NC}"
echo ""

cd ..
