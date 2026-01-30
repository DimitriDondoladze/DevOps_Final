# DEPLOYMENT_GUIDE.md - Complete Terraform & GitHub Actions Deployment

This guide walks you through every step to deploy the Flask application to AWS.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Setup](#local-setup)
3. [Terraform Configuration](#terraform-configuration)
4. [GitHub Actions Setup](#github-actions-setup)
5. [Deployment](#deployment)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### AWS Account Requirements
- AWS account with sufficient permissions
- User with `AdministratorAccess` or equivalent
- Ability to create VPC, RDS, ECS, ECR, IAM roles

### Local Tools

**Install Terraform:**
```bash
# Windows (using Chocolatey)
choco install terraform

# macOS
brew install terraform

# Verify installation
terraform version  # Should be >= 1.0
```

**Install AWS CLI:**
```bash
# Windows (using Chocolatey)
choco install awscli

# macOS
brew install awscli

# Verify installation
aws --version
```

**Install Docker:**
- Download from [docker.com](https://www.docker.com/products/docker-desktop)
- Verify: `docker --version`

### Git & GitHub
- GitHub account
- Repository: https://github.com/DimitriDondoladze/DevOps_Final
- Git installed locally

---

## Local Setup

### 1. Clone the Repository

```bash
git clone https://github.com/DimitriDondoladze/DevOps_Final.git
cd DevOps_Final
```

### 2. Verify Project Structure

```bash
# You should see:
# ├── app/
# │   ├── Dockerfile
# │   ├── app.py
# │   ├── requirements.txt
# │   └── .env.example
# ├── terraform/
# │   ├── main.tf
# │   ├── variables.tf
# │   ├── outputs.tf
# │   ├── terraform.tfvars
# │   └── modules/
# ├── .github/
# │   └── workflows/
# │       └── deploy.yml
# └── README.md
```

---

## Terraform Configuration

### 1. Review terraform.tfvars

**File**: `terraform/terraform.tfvars`

```hcl
aws_region     = "us-east-2"
app_name       = "devops-final"

# VPC Configuration (defaults are fine)
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
database_password            = "ChangeMe@12345"  # ← CHANGE THIS!
rds_skip_final_snapshot      = true
rds_publicly_accessible      = true
rds_multi_az                 = false
rds_backup_retention_period  = 7

# ECR Configuration
ecr_repository_name = "devops-final"

# ECS Configuration
ecs_task_cpu     = "256"      # Valid: 256, 512, 1024, 2048, 4096
ecs_task_memory  = "512"      # Must be valid for CPU
ecs_desired_count = 2
ecs_min_capacity = 1
ecs_max_capacity = 4

container_image = "nginx:latest"  # Placeholder
```

### 2. Customize Key Values

**Database Password** (IMPORTANT!):
```hcl
database_password = "MySecurePassword123!@#"
```

**Application Name** (optional):
```hcl
app_name = "my-app"  # Used as prefix for all resources
```

**Desired Count** (optional):
```hcl
ecs_desired_count = 2  # Number of running Flask containers
```

### 3. Initialize Terraform

Navigate to terraform directory and initialize:

```bash
cd terraform

# Download provider plugins
terraform init

# Verify all files are valid
terraform validate

# Format files to standards
terraform fmt -recursive
```

**Output should show:**
```
Terraform has been successfully initialized!
```

---

## GitHub Actions Setup

### 1. Get AWS Credentials

**Create IAM User for GitHub Actions:**

```bash
# Using AWS CLI
aws iam create-user --user-name github-actions-devops

# Create access key
aws iam create-access-key --user-name github-actions-devops
```

**Attach Policy:**
```bash
aws iam attach-user-policy \
  --user-name github-actions-devops \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

**Copy:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. Add Secrets to GitHub

**Navigate to:**
- GitHub Repository → **Settings** → **Secrets and Variables** → **Actions**

**Create New Secrets:**

| Secret Name | Value |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | Your access key |
| `AWS_SECRET_ACCESS_KEY` | Your secret key |

**Verify:** Secrets should be hidden (not visible in logs)

---

## Deployment

### Step 1: Local Terraform Plan

Before pushing to GitHub, test locally:

```bash
cd terraform

terraform plan -out=tfplan
```

Review output - should show all resources being created.

### Step 2: Apply Terraform (Optional Local Test)

```bash
terraform apply tfplan
```

**Wait** for completion (~10-15 minutes).

**Note**: You can also skip this and let GitHub Actions handle it.

### Step 3: Push to GitHub

```bash
cd ..  # Back to repo root

git add .
git commit -m "Deploy: Terraform infrastructure and GitHub Actions CI/CD"
git push origin main
```

### Step 4: Monitor GitHub Actions

**Go to:** Repository → **Actions** tab

**You should see workflow:** `Build and Deploy to ECS`

**Stages:**
1. ✅ **Build** - Builds Docker image
2. ✅ **Push** - Pushes to ECR
3. ✅ **Deploy** - Applies Terraform changes
4. ✅ **Notify** - Shows deployment status

**Monitor logs:**
- Click workflow run
- Click each job to see logs

---

## Verification

### 1. Check Terraform State

```bash
cd terraform

# View all resources created
terraform show

# View specific outputs
terraform output
```

**Should show:**
```
alb_dns_name = "devops-final-alb-XXXXX.us-east-2.elb.amazonaws.com"
ecr_repository_url = "XXXXX.dkr.ecr.us-east-2.amazonaws.com/devops-final"
ecs_cluster_name = "devops-final-cluster"
rds_endpoint = "devops-final-db.XXXXX.us-east-2.rds.amazonaws.com:3306"
```

### 2. Verify AWS Resources

**ECS Cluster:**
```bash
aws ecs describe-clusters \
  --cluster-names devops-final-cluster \
  --region us-east-2
```

**ECS Service:**
```bash
aws ecs describe-services \
  --cluster devops-final-cluster \
  --services devops-final-service \
  --region us-east-2
```

**ECS Tasks:**
```bash
aws ecs list-tasks \
  --cluster devops-final-cluster \
  --region us-east-2

# Get task details
aws ecs describe-tasks \
  --cluster devops-final-cluster \
  --tasks <task-arn> \
  --region us-east-2
```

**RDS Database:**
```bash
aws rds describe-db-instances \
  --db-instance-identifier devops-final-db \
  --region us-east-2
```

**ECR Repository:**
```bash
aws ecr describe-repositories \
  --repository-names devops-final \
  --region us-east-2

# List images
aws ecr list-images \
  --repository-name devops-final \
  --region us-east-2
```

### 3. Test Application

**Get ALB DNS:**
```bash
aws elbv2 describe-load-balancers \
  --names devops-final-alb \
  --region us-east-2 | grep DNSName
```

**Or from Terraform:**
```bash
terraform output alb_dns_name
```

**Test endpoints:**

```bash
ALB_DNS="<YOUR_ALB_DNS_NAME>"

# Health check
curl http://$ALB_DNS/

# Database connectivity
curl http://$ALB_DNS/db
```

**Expected responses:**
- `/` → `Hello from AWS DevOps Final Project`
- `/db` → `{"status": "success", "db_response": 1}`

### 4. Check CloudWatch Logs

```bash
# View logs
aws logs tail /ecs/devops-final --follow --region us-east-2

# Or in AWS Console:
# CloudWatch → Logs → /ecs/devops-final
```

---

## Troubleshooting

### ECS Tasks Not Starting

**Check task definition:**
```bash
aws ecs describe-task-definition \
  --task-definition devops-final \
  --region us-east-2
```

**View task logs:**
```bash
aws logs tail /ecs/devops-final --follow
```

### Database Connection Errors

**Verify RDS is running:**
```bash
aws rds describe-db-instances \
  --db-instance-identifier devops-final-db \
  --region us-east-2 | grep DBInstanceStatus
```

**Check security group:**
```bash
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=devops-final-rds-sg \
  --region us-east-2
```

### ALB Not Routing Traffic

**Check target health:**
```bash
# Get target group ARN
TG_ARN=$(aws elbv2 describe-target-groups \
  --load-balancer-arn <alb-arn> \
  --region us-east-2 \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Check health
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --region us-east-2
```

### Terraform Errors

**Common errors:**

```bash
# Error: Invalid API credentials
# Solution: Check AWS credentials in GitHub Secrets

# Error: InsufficientCapacityException
# Solution: Try different instance type or region

# Error: Database already exists
# Solution: Change database_name in terraform.tfvars
```

---

## Security Notes

### 🔒 Database Password

- Change default password in `terraform.tfvars`
- Use strong password: min 12 chars, mixed case, numbers, symbols
- Store securely - don't commit to Git

### 🔐 AWS Credentials

- Use IAM user for GitHub Actions, not root account
- Rotate access keys regularly
- Delete credentials after deployment if not needed

### 🔑 Terraform State

- Local state stores sensitive data (passwords, connection strings)
- Add `.tfstate` to `.gitignore` (already done)
- For production, use S3 backend with encryption

---

## Next Steps

1. ✅ Verify application is running
2. ✅ Take screenshots for assessment submission
3. ✅ Test database connectivity
4. ✅ Review CloudWatch logs and monitoring
5. ✅ Clean up resources before submission deadline

---

## Additional Commands

```bash
# View all Terraform outputs
terraform output

# Refresh state (sync with AWS)
terraform refresh

# Destroy all resources
terraform destroy

# Validate Terraform syntax
terraform validate

# Format Terraform code
terraform fmt -recursive

# See resource changes before apply
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show specific resource
terraform show aws_ecs_cluster.main
```

---

**For assessment submission, follow**: [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)
