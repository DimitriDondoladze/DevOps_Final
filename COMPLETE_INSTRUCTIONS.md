# COMPLETE_INSTRUCTIONS.md - Step-by-Step for Beginners

Complete, beginner-friendly guide with every command and screenshot explanation.

## 📋 What We'll Do

1. ✅ Setup local development environment
2. ✅ Configure Terraform for AWS
3. ✅ Setup GitHub Actions secrets
4. ✅ Deploy infrastructure to AWS
5. ✅ Test the application
6. ✅ Monitor and cleanup

**Total time**: ~30 minutes setup + ~15 minutes deployment

---

## Part 1: Local Setup (10 minutes)

### 1.1 Install Required Tools

#### Terraform
```bash
# Windows (using Chocolatey - if installed)
choco install terraform

# macOS (using Homebrew)
brew install terraform

# Verify
terraform --version
# Expected: Terraform v1.x.x
```

#### AWS CLI
```bash
# Windows (using Chocolatey)
choco install awscli

# macOS
brew install awscli

# Verify
aws --version
# Expected: aws-cli/2.x.x
```

#### Git
- Download from https://git-scm.com/
- Install with default settings
- Verify: `git --version`

### 1.2 Clone Repository

```bash
# Open terminal/PowerShell
cd Desktop

# Clone
git clone https://github.com/DimitriDondoladze/DevOps_Final.git
cd DevOps_Final

# Check structure
ls -la
# You should see: app/, terraform/, .github/, README.md
```

### 1.3 Check Terraform Files

```bash
cd terraform

# List files
ls -la

# Should see:
# main.tf
# variables.tf
# outputs.tf
# terraform.tfvars
# modules/ (folder)
```

---

## Part 2: Configure Terraform (5 minutes)

### 2.1 Edit terraform.tfvars

**File**: `terraform/terraform.tfvars`

**Change these values:**

```hcl
# Line 1: Region (already correct)
aws_region     = "us-east-2"

# Line 2: App name (optional, keep as is)
app_name       = "devops-final"

# Around line 18-19: Database password (IMPORTANT!)
database_password = "MyPassword@123456"  # Change this!

# Everything else: Keep default
```

**How to edit:**
- Open file in VS Code or text editor
- Find `database_password = "ChangeMe@12345"`
- Replace with your password (min 12 chars)
- Save file

### 2.2 Validate Configuration

```bash
# From terraform/ folder
terraform init

# Expected output:
# Terraform has been successfully initialized!
# Backend type: local
# Working Directory: /path/to/terraform
```

```bash
# Validate syntax
terraform validate

# Expected output:
# Success! The configuration is valid.
```

---

## Part 3: AWS Setup (10 minutes)

### 3.1 Create IAM User for GitHub Actions

**Using AWS Console (easier for beginners):**

1. Go to: https://console.aws.amazon.com/iam/
2. Left menu → **Users**
3. Click **Create user**
4. Name: `github-actions-devops`
5. Click **Next**
6. Permissions → **Attach policies directly**
7. Search: `AdministratorAccess`
8. ✓ Check box
9. Click **Next** → **Create user**

### 3.2 Create Access Keys

1. Click the new user: `github-actions-devops`
2. **Security credentials** tab
3. **Access keys** section
4. Click **Create access key**
5. Choose: **Command Line Interface (CLI)**
6. ✓ Acknowledge
7. Click **Create access key**
8. **Copy these values:**
   - Access Key ID
   - Secret Access Key

**⚠️ IMPORTANT: Store these securely - you won't see them again!**

---

## Part 4: GitHub Actions Setup (5 minutes)

### 4.1 Add AWS Credentials to GitHub

1. Go to repository: https://github.com/DimitriDondoladze/DevOps_Final
2. Click **Settings** (top right)
3. Left menu → **Secrets and variables** → **Actions**
4. Click **New repository secret**

**Create Secret #1:**
- Name: `AWS_ACCESS_KEY_ID`
- Value: Paste your Access Key ID
- Click **Add secret**

**Create Secret #2:**
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Paste your Secret Access Key
- Click **Add secret**

**Verify:** Both secrets should appear in the list (values hidden)

### 4.2 Verify Workflow File

```bash
# Check workflow exists
cat .github/workflows/deploy.yml

# Should show 'Build and Deploy to ECS' workflow
```

---

## Part 5: Deploy (2 minutes)

### 5.1 Push Code to GitHub

```bash
# From repo root
git add .
git commit -m "Deploy: Infrastructure as Code with Terraform"
git push origin main

# If asked for credentials, enter GitHub username and token
```

### 5.2 Monitor Deployment

1. Go to repository: https://github.com/DimitriDondoladze/DevOps_Final
2. Click **Actions** tab
3. You should see: **"Build and Deploy to ECS"** workflow running

**Workflow stages:**
```
✅ Build      - Building Docker image
✅ Push       - Pushing to ECR
✅ Deploy     - Running Terraform apply
✅ Notify     - Deployment complete
```

**⏱️ Wait**: 10-15 minutes for completion

**Monitor real-time logs:**
- Click workflow run
- Click each stage to see detailed logs

---

## Part 6: Verify Deployment (5 minutes)

### 6.1 Get Application URL

After deployment completes:

```bash
cd terraform

terraform output alb_dns_name
```

**Output example:**
```
devops-final-alb-123456.us-east-2.elb.amazonaws.com
```

### 6.2 Test Application

Open browser and visit:
```
http://devops-final-alb-123456.us-east-2.elb.amazonaws.com
```

**You should see:**
```
Hello from AWS DevOps Final Project
```

### 6.3 Test Database Connection

Visit:
```
http://devops-final-alb-123456.us-east-2.elb.amazonaws.com/db
```

**You should see:**
```json
{
  "status": "success",
  "db_response": 1
}
```

---

## Part 7: View Infrastructure in AWS Console

### 7.1 VPC & Networking
1. AWS Console → **VPC**
2. Check:
   - VPC created: `devops-final-vpc`
   - Subnets: 4 subnets
   - NAT Gateway: 1 NAT Gateway
   - ALB: Listed under Load Balancers

### 7.2 RDS Database
1. AWS Console → **RDS**
2. Check:
   - Instance: `devops-final-db`
   - Status: Available
   - Endpoint: `devops-final-db.xxxxx.us-east-2.rds.amazonaws.com`

### 7.3 ECS Cluster
1. AWS Console → **ECS**
2. Check:
   - Cluster: `devops-final-cluster`
   - Service: `devops-final-service`
   - Running tasks: 2 (or your desired count)

### 7.4 ECR Repository
1. AWS Console → **ECR**
2. Check:
   - Repository: `devops-final`
   - Images: Latest pushed image with tag

### 7.5 CloudWatch Logs
1. AWS Console → **CloudWatch → Logs**
2. Log group: `/ecs/devops-final`
3. Check for application logs

---

## Part 8: Monitoring (Optional)

### View Application Logs

```bash
# Using AWS CLI
aws logs tail /ecs/devops-final --follow --region us-east-2

# Or in AWS Console:
# CloudWatch → Log groups → /ecs/devops-final
```

### Check ECS Task Health

```bash
# List running tasks
aws ecs list-tasks \
  --cluster devops-final-cluster \
  --region us-east-2

# Get task details
aws ecs describe-tasks \
  --cluster devops-final-cluster \
  --tasks arn:aws:ecs:... \
  --region us-east-2
```

### Check Auto Scaling

1. AWS Console → **EC2 → Auto Scaling**
2. Look for auto scaling group with `devops-final`
3. View current/desired/minimum/maximum capacity

---

## Part 9: Cleanup (To Avoid Charges!)

⚠️ **DELETE ALL RESOURCES WHEN DONE** to avoid AWS charges.

### 9.1 Destroy Infrastructure

```bash
cd terraform

terraform destroy
```

**Confirmation:**
```
Enter a value: yes
```

⏱️ **Wait** 5-10 minutes for deletion

### 9.2 Verify Deletion

```bash
# Check state
terraform show
# Should be empty

# AWS Console verification:
# - RDS: No instances
# - ECS: No clusters
# - ECR: No repositories
# - VPC: No custom VPCs
# - ALB: No load balancers
```

### 9.3 Delete IAM User (Optional)

```bash
# Delete access keys first
aws iam delete-access-key \
  --user-name github-actions-devops \
  --access-key-id <KEY_ID>

# Delete user
aws iam delete-user --user-name github-actions-devops
```

---

## Common Issues & Solutions

### Issue: "terraform: command not found"
**Solution:** Terraform not installed. Run: `choco install terraform` (Windows) or `brew install terraform` (Mac)

### Issue: "AWS credentials not found"
**Solution:** Check GitHub Secrets are added correctly. Go to: Settings → Secrets and Variables → Actions

### Issue: "ECS tasks not starting"
**Solution:** Check CloudWatch logs:
```bash
aws logs tail /ecs/devops-final --follow
```

### Issue: "Cannot connect to database"
**Solution:** Database takes ~5 minutes to initialize. Wait, then retry.

### Issue: "ALB returns 502 Bad Gateway"
**Solution:** ECS tasks not healthy yet. Wait 2-3 minutes and retry.

### Issue: "Terraform destroy fails"
**Solution:** Delete manually via AWS Console if stuck:
1. Delete ECS service first
2. Delete RDS instance
3. Delete ALB
4. Then run `terraform destroy` again

---

## Quick Reference

### URLs
- **Repository**: https://github.com/DimitriDondoladze/DevOps_Final
- **AWS Console**: https://console.aws.amazon.com
- **Application**: http://\<ALB_DNS_NAME\>

### Key Terraform Commands

```bash
# Navigate to terraform folder
cd terraform

# Initialize
terraform init

# Validate
terraform validate

# View plan
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy (cleanup)
terraform destroy
```

### Key AWS CLI Commands

```bash
# View ECS cluster status
aws ecs describe-clusters --cluster-names devops-final-cluster

# View running tasks
aws ecs list-tasks --cluster devops-final-cluster

# View logs
aws logs tail /ecs/devops-final --follow

# View RDS status
aws rds describe-db-instances --db-instance-identifier devops-final-db
```

---

## Next Steps

1. ✅ Verify application is running
2. ✅ Take screenshots for assessment
3. ✅ Document your deployment
4. ✅ Clean up before submitting

**See**: [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)

---

**Questions?** Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for more details.
