# INSTRUCTIONS.md - Quick Start Summary for Your Deployment

## 🎯 What You Have

Complete Infrastructure-as-Code deployment with:
- ✅ Flask application with MySQL database connectivity
- ✅ Terraform modules for all AWS resources
- ✅ GitHub Actions CI/CD pipeline
- ✅ Comprehensive documentation

## 📋 Key Configuration Details

| Item | Value |
|------|-------|
| **AWS Region** | `us-west-2` |
| **Application** | Flask (Python 3.9) |
| **Database** | MySQL 8.0.35 (RDS) |
| **Container Orchestration** | ECS Fargate |
| **Container Registry** | ECR |
| **Load Balancer** | Application Load Balancer (ALB) |
| **CI/CD** | GitHub Actions |
| **Infrastructure** | Terraform (modular, local state) |
| **Application Port** | 5000 |
| **Database Port** | 3306 |
| **Flask Environment** | production |

## 🔧 Database Credentials (To Be Set)

**File**: `terraform/terraform.tfvars` (line 18-19)

```hcl
database_user     = "admin"
database_password = "YOUR_SECURE_PASSWORD_HERE"  # ← CHANGE THIS
database_name     = "appdb"
```

**Generate a strong password** (min 12 chars):
```
Example: Mystrong@Pass123456
```

## 🔐 GitHub Actions Secrets (To Be Added)

**Go to**: GitHub Repository → Settings → Secrets and Variables → Actions

**Add Two Secrets**:

| Secret Name | Where to Get |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM Console (User: github-actions-devops) |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM Console (User: github-actions-devops) |

**To create IAM user:**
```bash
# AWS CLI (after you have local credentials configured)
aws iam create-user --user-name github-actions-devops
aws iam create-access-key --user-name github-actions-devops
aws iam attach-user-policy --user-name github-actions-devops \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Or use AWS Console → IAM → Users → Create user

## 🚀 Deployment Steps

### Option 1: Deploy via GitHub Actions (Recommended for Submission)

1. **Customize `terraform/terraform.tfvars`**
   ```bash
   # Change database_password to something strong
   # Keep everything else as default
   ```

2. **Add AWS credentials to GitHub Secrets**
   - Settings → Secrets and Variables → Actions
   - Add: `AWS_ACCESS_KEY_ID`
   - Add: `AWS_SECRET_ACCESS_KEY`

3. **Push to Main Branch**
   ```bash
   git add .
   git commit -m "Deploy: Infrastructure and CI/CD pipeline"
   git push origin main
   ```

4. **Monitor Deployment**
   - Go to: GitHub Repository → Actions
   - Watch workflow: "Build and Deploy to ECS"
   - Wait 15-20 minutes for completion

### Option 2: Deploy Locally (For Testing)

1. **Customize Configuration**
   ```bash
   cd terraform
   
   # Edit terraform.tfvars
   # Change: database_password = "YOUR_STRONG_PASSWORD"
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   terraform validate
   ```

3. **Apply Infrastructure**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

4. **Capture Outputs**
   ```bash
   terraform output
   # Copy: alb_dns_name
   ```

5. **Test Application**
   ```bash
   curl http://<ALB_DNS_NAME>/
   curl http://<ALB_DNS_NAME>/db
   ```

6. **Destroy When Done**
   ```bash
   terraform destroy
   ```

## ✅ Verification Checklist

After deployment, verify:

- [ ] **ECS Cluster**: Running in AWS Console
- [ ] **ECS Service**: Shows 2 running tasks
- [ ] **RDS Instance**: Status = Available
- [ ] **ECR Repository**: Has pushed images
- [ ] **ALB**: Shows active listeners
- [ ] **Application**: Accessible via ALB DNS
- [ ] **Endpoint /**: Returns "Hello from AWS DevOps Final Project"
- [ ] **Endpoint /db**: Returns JSON with "success" status
- [ ] **CloudWatch Logs**: Shows application startup logs
- [ ] **GitHub Actions**: Workflow completed successfully

## 📸 Screenshots for Assessment

Capture these for your PDF submission:

**Task 1 - Repository Setup**
- GitHub repo main page
- app.py code
- README.md

**Task 2 - RDS Database**
- terraform/modules/rds/main.tf
- terraform/terraform.tfvars (mask password)
- AWS Console → RDS instance details
- Security group inbound rules

**Task 3 - Containerization**
- app/Dockerfile
- terraform/modules/ecr/main.tf
- AWS Console → ECR repository with images

**Task 4 - CI/CD Pipeline**
- .github/workflows/deploy.yml
- GitHub Actions → Workflow run (successful)
- Build, deploy, and notify stages

**Task 5 - ECS Deployment**
- terraform/modules/ecs/main.tf
- AWS Console → ECS cluster running
- AWS Console → ECS service with 2 tasks
- Browser showing: http://ALB_DNS_NAME/ response
- Browser showing: http://ALB_DNS_NAME/db response

**Task 6 - Monitoring & Cleanup**
- AWS Console → CloudWatch logs
- AWS Console → CloudWatch metrics
- Terraform destroy output
- AWS Console showing deleted resources

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| **README.md** | Project overview and quick start |
| **COMPLETE_INSTRUCTIONS.md** | Beginner-friendly step-by-step guide |
| **DEPLOYMENT_GUIDE.md** | Detailed deployment with AWS CLI commands |
| **SUBMISSION_CHECKLIST.md** | Assessment submission requirements |
| **INSTRUCTIONS.md** | This file - quick reference |

## 🔑 Important Environment Variables

**Automatically set by ECS task definition**:

```
FLASK_ENV = production
DB_HOST = <RDS_ENDPOINT>
DB_PORT = 3306
DB_NAME = appdb
DB_USER = admin
DB_PASSWORD = <YOUR_PASSWORD>
PORT = 5000
```

## 🧹 Cleanup (IMPORTANT!)

**To avoid AWS charges, destroy resources when done**:

```bash
cd terraform
terraform destroy

# Confirm: yes

# Wait 5-10 minutes for deletion
```

**Verify deletion**:
- AWS Console → RDS: No instances
- AWS Console → ECS: No clusters
- AWS Console → ECR: No repositories
- AWS Console → VPC: Only default VPC

## 🆘 Troubleshooting

**Issue**: ECS tasks not starting
```bash
aws logs tail /ecs/devops-final --follow --region us-west-2
```

**Issue**: Database connection error
- Check RDS status: Available?
- Check security group: Port 3306 open from ECS?
- Wait 5 minutes for RDS to fully initialize

**Issue**: ALB returning 502
- Wait 2-3 minutes for tasks to become healthy
- Check target group health: AWS Console → EC2 → Target Groups

**Issue**: GitHub Actions failing
- Verify AWS credentials in Secrets
- Check credential permissions (AdministratorAccess needed)
- View workflow logs for specific error

**Issue**: Terraform state issues
```bash
# View current state
terraform show

# Refresh state
terraform refresh

# Show specific resource
terraform state show aws_ecs_service.app
```

## 📝 Database Connection String

Once deployed, your application connects using:

```
mysql://admin:<PASSWORD>@<RDS_ENDPOINT>:3306/appdb
```

**Example**:
```
mysql://admin:MyPassword@123@devops-final-db.abc123.us-west-2.rds.amazonaws.com:3306/appdb
```

**RDS endpoint found in**:
```bash
# From terraform output
terraform output rds_endpoint

# Or AWS Console → RDS → Databases → devops-final-db
```

## 🔗 Useful Links

- **GitHub Repository**: https://github.com/DimitriDondoladze/DevOps_Final
- **AWS Console**: https://console.aws.amazon.com
- **Terraform Docs**: https://www.terraform.io/docs
- **AWS CLI Reference**: https://docs.aws.amazon.com/cli
- **ECS Documentation**: https://docs.aws.amazon.com/ecs

## 📞 Quick Commands Reference

```bash
# Terraform
cd terraform
terraform init              # Initialize
terraform validate          # Check syntax
terraform plan -out=tfplan  # Show changes
terraform apply tfplan      # Deploy
terraform destroy           # Clean up
terraform output            # View outputs
terraform show              # View state

# AWS CLI
aws ecs describe-clusters --cluster-names devops-final-cluster
aws ecs list-tasks --cluster devops-final-cluster
aws logs tail /ecs/devops-final --follow
aws rds describe-db-instances --db-instance-identifier devops-final-db
aws ecr list-images --repository-name devops-final

# Git
git add .
git commit -m "message"
git push origin main
git status
```

## ✨ Next Steps

1. **Customize `terraform/terraform.tfvars`**
2. **Create GitHub Actions Secrets** with AWS credentials
3. **Push to main branch** to trigger CI/CD
4. **Monitor deployment** in GitHub Actions
5. **Test application** using ALB DNS name
6. **Capture screenshots** for assessment submission
7. **Destroy resources** before final submission

---

## Questions?

- **For beginners**: See [COMPLETE_INSTRUCTIONS.md](COMPLETE_INSTRUCTIONS.md)
- **For detailed steps**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **For submission help**: See [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)

---

**Project Version**: 1.0  
**Last Updated**: January 2026  
**Terraform State**: Local (terraform.tfstate)
