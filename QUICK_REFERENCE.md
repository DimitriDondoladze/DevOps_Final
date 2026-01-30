# QUICK_REFERENCE.md - Visual Guide & Cheat Sheet

## 📌 3-Step Quick Deploy

### STEP 1️⃣: Customize Password (1 min)
```
File: terraform/terraform.tfvars
Line 18: database_password = "YourSecurePassword@123"
```

### STEP 2️⃣: Add GitHub Secrets (5 min)
```
GitHub → Settings → Secrets and Variables → Actions

SECRET 1: AWS_ACCESS_KEY_ID = (from IAM user)
SECRET 2: AWS_SECRET_ACCESS_KEY = (from IAM user)
```

### STEP 3️⃣: Deploy! (20 min)
```bash
git add . && git commit -m "Deploy" && git push origin main
```

Monitor: GitHub Repository → Actions tab → Watch workflow run

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│          PUBLIC INTERNET - PORT 80/443          │
└────────────────┬─────────────────────────────────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │ Application Load Balancer  │  (Public subnets)
    │     (devops-final-alb)     │
    └─────────┬──────────────────┘
              │
    ┌─────────┴──────────────────┐
    │                            │
    ▼                            ▼
┌──────────────┐          ┌──────────────┐
│  ECS Task 1  │          │  ECS Task 2  │  (Private subnets)
│   Port 5000  │          │   Port 5000  │
│  (Fargate)   │          │  (Fargate)   │
└──────┬───────┘          └──────┬───────┘
       │                         │
       └────────────┬────────────┘
                    │
                    ▼
          ┌──────────────────────┐
          │   RDS MySQL (3306)   │  (Private subnets)
          │  devops-final-db     │
          │  (db.t3.micro)       │
          └──────────────────────┘

 NAT Gateway → Outbound Internet Access (Private subnets)
 Security Groups → Firewall Rules
 VPC (10.0.0.0/16) → Network Isolation
```

---

## 📂 File Organization

```
Your Project Root
├── 📄 INSTRUCTIONS.md ← START HERE
├── 📄 COMPLETE_INSTRUCTIONS.md (beginner guide)
├── 📄 DEPLOYMENT_GUIDE.md (detailed)
├── 📄 SUBMISSION_CHECKLIST.md (for assessment)
├── 📄 PROJECT_SUMMARY.md (overview)
│
├── app/
│   ├── app.py (Flask application)
│   ├── Dockerfile (container definition)
│   ├── requirements.txt (dependencies)
│   └── .env.example (env template)
│
├── terraform/
│   ├── main.tf ← USES MODULES
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars ← CUSTOMIZE
│   ├── terraform.tfstate (auto-generated)
│   └── modules/
│       ├── vpc/
│       ├── security-groups/
│       ├── rds/
│       ├── ecr/
│       ├── alb/
│       └── ecs/
│
├── .github/
│   └── workflows/
│       └── deploy.yml (CI/CD)
│
└── setup.sh (automation script)
```

---

## 🔑 Important Values

### AWS Services & Naming
```
Region:         us-west-2
App Name:       devops-final
VPC CIDR:       10.0.0.0/16

Public Subnets:   10.0.1.0/24, 10.0.2.0/24
Private Subnets:  10.0.10.0/24, 10.0.11.0/24

ECS Cluster:    devops-final-cluster
ECS Service:    devops-final-service
ALB Name:       devops-final-alb
RDS Instance:   devops-final-db
ECR Repo:       devops-final
```

### Database
```
Engine:         MySQL 8.0.35
Instance:       db.t3.micro
Storage:        20 GB
User:           admin
Password:       YOUR_PASSWORD (in terraform.tfvars)
Database:       appdb
Port:           3306
Location:       Private subnets
Public Access:  Yes (for testing)
```

### Application
```
Port:           5000
Framework:      Flask (Python 3.9)
Load Balancer:  ALB
Health Check:   /
DB Endpoint:    /db
```

### ECS Configuration
```
CPU:            256 units (0.25 vCPU)
Memory:         512 MB
Desired Tasks:  2
Min Tasks:      1
Max Tasks:      4
```

---

## 🔐 GitHub Actions Secrets (What to Add)

```
Name: AWS_ACCESS_KEY_ID
Value: AKIA...

Name: AWS_SECRET_ACCESS_KEY
Value: kN...
```

❌ NEVER commit these to Git!

---

## 📱 Testing Endpoints

### Endpoint 1: Health Check
```
GET http://<ALB_DNS_NAME>/

Expected Response:
Hello from AWS DevOps Final Project

Status Code: 200 OK
```

### Endpoint 2: Database Check
```
GET http://<ALB_DNS_NAME>/db

Expected Response:
{
  "status": "success",
  "db_response": 1
}

Status Code: 200 OK
```

---

## 🎯 Terraform Commands Cheat Sheet

```bash
# Navigate to terraform folder
cd terraform

# Initial setup
terraform init          # Download providers
terraform validate      # Check syntax
terraform fmt -r .      # Format all files

# Planning
terraform plan          # Show what will be created
terraform plan -o tfplan  # Save plan to file

# Deployment
terraform apply tfplan  # Apply saved plan
terraform apply         # Ask to apply (interactive)

# Verification
terraform output        # Show outputs
terraform show          # Show current state
terraform show <resource>  # Show specific resource

# State management
terraform state list    # List resources
terraform state show <resource>  # Details
terraform refresh       # Sync with AWS

# Cleanup
terraform destroy       # Delete everything
```

---

## 📊 AWS CLI Verification Commands

```bash
# ECS Cluster Status
aws ecs describe-clusters \
  --cluster-names devops-final-cluster \
  --region us-west-2

# Running Tasks
aws ecs list-tasks \
  --cluster devops-final-cluster \
  --region us-west-2

# Task Details
aws ecs describe-tasks \
  --cluster devops-final-cluster \
  --tasks <TASK_ARN> \
  --region us-west-2

# RDS Database Status
aws rds describe-db-instances \
  --db-instance-identifier devops-final-db \
  --region us-west-2

# ECR Images
aws ecr list-images \
  --repository-name devops-final \
  --region us-west-2

# CloudWatch Logs
aws logs tail /ecs/devops-final \
  --follow \
  --region us-west-2

# ALB Status
aws elbv2 describe-load-balancers \
  --names devops-final-alb \
  --region us-west-2
```

---

## ⏱️ Timeline

```
Action              | Duration  | Notes
--------------------|-----------|---------------------------
git push            | Instant   | Triggers workflow
Docker build        | 2-3 min   | Building image
Push to ECR         | 1 min     | Registry operation
Terraform init      | 1 min     | First time only
VPC creation        | 2 min     | Network setup
RDS creation        | 5-8 min   | Database startup (slowest)
ECS setup           | 2-3 min   | Container orchestration
Total               | ~15 min   | Full deployment

Cleanup (destroy)   | 5-10 min  | Delete all resources
```

---

## 🚨 Common Issues & Quick Fixes

```
ISSUE: ECS tasks not starting
FIX:   aws logs tail /ecs/devops-final --follow

ISSUE: Database connection error  
FIX:   Check RDS status is "Available"
       Check security group port 3306 open

ISSUE: ALB returning 502 Bad Gateway
FIX:   Wait 2-3 minutes for tasks to be healthy
       Check target group health

ISSUE: GitHub Actions failing
FIX:   Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in Secrets

ISSUE: Terraform validation fails
FIX:   terraform fmt -recursive
       terraform validate

ISSUE: Can't connect to RDS
FIX:   RDS takes 5+ minutes to initialize
       Verify security group allows ECS → RDS 3306
       Check RDS publicly_accessible = true
```

---

## 📋 Assessment Submission Checklist

```
TASK 1: Repository Setup
☐ Screenshot of GitHub repo
☐ Screenshot of app.py
☐ Description of functionality

TASK 2: RDS Database
☐ Screenshot of RDS Terraform code
☐ Screenshot of security group rules
☐ AWS Console screenshot showing RDS instance
☐ Explanation of connectivity

TASK 3: Containerization
☐ Screenshot of Dockerfile
☐ Screenshot of ECR module code
☐ AWS Console showing ECR repository
☐ List of pushed images

TASK 4: CI/CD Pipeline
☐ Screenshot of deploy.yml
☐ Screenshot of GitHub Actions workflow run
☐ Build, Deploy, Notify stage details
☐ Explanation of pipeline stages

TASK 5: ECS Deployment
☐ Screenshot of ECS module code
☐ AWS Console showing ECS cluster
☐ AWS Console showing running tasks (2)
☐ Browser showing / endpoint response
☐ Browser showing /db endpoint response
☐ Auto scaling configuration details

TASK 6: Monitoring & Cleanup
☐ Screenshot of CloudWatch logs
☐ Screenshot of CloudWatch metrics
☐ Terraform destroy output
☐ Screenshot of deleted resources
☐ Explanation of monitoring strategy
```

---

## 🔗 Quick Links

```
GitHub Repo:    https://github.com/DimitriDondoladze/DevOps_Final
AWS Console:    https://console.aws.amazon.com
Terraform Docs: https://www.terraform.io/docs
AWS CLI Docs:   https://docs.aws.amazon.com/cli
ECS Docs:       https://docs.aws.amazon.com/ecs
RDS Docs:       https://docs.aws.amazon.com/rds
ECR Docs:       https://docs.aws.amazon.com/ecr
```

---

## 🎓 What Each Terraform Module Does

| Module | Creates | Purpose |
|--------|---------|---------|
| **vpc** | VPC, Subnets, NAT Gateway | Networking foundation |
| **security-groups** | 3 Security Groups | Firewall rules |
| **rds** | MySQL Database Instance | Data persistence |
| **ecr** | Container Repository | Image registry |
| **alb** | Load Balancer + Target Group | Traffic distribution |
| **ecs** | Cluster, Service, Task Def | Container orchestration |

---

## 💾 State Files

```
Local State: terraform.tfstate
├── Stores current state of all resources
├── Contains sensitive data (passwords!)
├── Git ignored (not in GitHub)
├── Auto-backed up as terraform.tfstate.backup
└── Deleted when you run: terraform destroy
```

---

## 🌐 Networking Overview

```
┌────────────────────────────────────────────────┐
│            VPC 10.0.0.0/16                     │
│                                                │
│  ┌─────────────────────────────────────────┐  │
│  │    PUBLIC SUBNETS (ALB, NAT GW)        │  │
│  │  - 10.0.1.0/24 (us-west-2a)           │  │
│  │  - 10.0.2.0/24 (us-west-2b)           │  │
│  │  Routes → Internet Gateway (0.0.0.0/0) │  │
│  └─────────────────────────────────────────┘  │
│                                                │
│  ┌─────────────────────────────────────────┐  │
│  │    PRIVATE SUBNETS (ECS, RDS)          │  │
│  │  - 10.0.10.0/24 (us-west-2a)          │  │
│  │  - 10.0.11.0/24 (us-west-2b)          │  │
│  │  Routes → NAT Gateway (0.0.0.0/0)     │  │
│  └─────────────────────────────────────────┘  │
│                                                │
└────────────────────────────────────────────────┘
```

---

## ✅ Pre-Launch Checklist

Before running: `git push origin main`

```
☐ terraform.tfvars password changed
☐ AWS IAM user created (github-actions-devops)
☐ AWS access key created
☐ GitHub secrets added (both)
☐ Terraform files formatted (terraform fmt -r)
☐ Terraform validated (terraform validate)
☐ GitHub repo is up to date
☐ Local changes committed
```

---

**Need more detail? See [INSTRUCTIONS.md](INSTRUCTIONS.md) or [COMPLETE_INSTRUCTIONS.md](COMPLETE_INSTRUCTIONS.md)**
