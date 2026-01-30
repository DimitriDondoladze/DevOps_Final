# DevOps Final Project - AWS Deployment with Terraform & GitHub Actions

A complete Infrastructure-as-Code solution for deploying a Flask application to AWS using Fargate ECS, RDS MySQL, and CI/CD with GitHub Actions.

## 🎯 Project Overview

This project demonstrates a fully managed AWS architecture with:
- **VPC** with public and private subnets across 2 AZs
- **ALB** (Application Load Balancer) for traffic distribution
- **ECS Fargate** for container orchestration
- **RDS MySQL** for persistent database
- **ECR** for container image registry
- **Auto Scaling** for dynamic capacity management
- **CloudWatch** for logging and monitoring
- **GitHub Actions** for CI/CD automation

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet (0.0.0.0/0)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │ 80/443
                       ▼
           ┌───────────────────────┐
           │  Application Load     │
           │     Balancer (ALB)    │
           └───────────┬───────────┘
                       │
       ┌───────────────┴───────────────┐
       │                               │
       ▼                               ▼
   ┌────────────┐              ┌────────────┐
   │  ECS Task  │              │  ECS Task  │
   │  (Fargate) │              │  (Fargate) │
   │  Port 5000 │              │  Port 5000 │
   └─────┬──────┘              └─────┬──────┘
         │                           │
         └───────────────┬───────────┘
                         │
                         ▼
           ┌─────────────────────────┐
           │   RDS MySQL Database    │
           │    (Private Subnet)     │
           │      Port 3306          │
           └─────────────────────────┘
```

## 📋 Technology Stack

- **IaC**: Terraform (modular structure)
- **Container Registry**: Amazon ECR
- **Container Orchestration**: Amazon ECS Fargate
- **Database**: Amazon RDS (MySQL 8.0.35)
- **Load Balancing**: AWS ALB
- **Networking**: AWS VPC with NAT Gateway
- **Logging**: CloudWatch Logs
- **CI/CD**: GitHub Actions
- **Monitoring**: CloudWatch Metrics & Auto Scaling

## 🚀 Quick Start

### Prerequisites
- AWS Account with appropriate permissions
- GitHub account and repository
- Terraform installed (v1.0+)
- AWS CLI installed
- Docker installed locally

### 1. Customize Configuration

Edit [terraform/terraform.tfvars](terraform/terraform.tfvars):

```hcl
aws_region          = "us-west-2"
app_name            = "devops-final"
database_password   = "ChangeMe@YourSecurePassword123"  # ← IMPORTANT!
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
terraform validate
```

### 3. Apply Infrastructure

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Capture Outputs

```bash
terraform output
```

## 🔐 GitHub Actions Setup

### Add AWS Credentials to Secrets

**Settings → Secrets and Variables → Actions**

Add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Push to Main

```bash
git push origin main
```

## 📊 Access Your Application

```bash
terraform output alb_dns_name
```

Then visit: `http://<ALB_DNS_NAME>`

### Test Endpoints

- **Home**: `http://<ALB_DNS_NAME>/`
- **DB Check**: `http://<ALB_DNS_NAME>/db`

## 🧹 Cleanup

```bash
cd terraform
terraform destroy
```

## 📚 Documentation

- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**: Detailed deployment steps
- **[COMPLETE_INSTRUCTIONS.md](COMPLETE_INSTRUCTIONS.md)**: Beginner-friendly guide
- **[SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)**: Assessment submission
