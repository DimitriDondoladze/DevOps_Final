# SUBMISSION_CHECKLIST.md - Assessment Submission Guide

This checklist maps each assignment task to deliverables and what screenshots/code to submit.

---

## Assessment Overview

**File Format**: Single PDF named `DevOps_Final_STUDENT_NAME.pdf`

**Submission Type**: Terraform (Infrastructure as Code) with explanations

---

## Task 1: Application and Repository Setup (5 pts)

### ✅ Deliverables

**Submit:**
- GitHub repository screenshot
- README.md screenshot or content
- Application functionality explanation

### 📸 Screenshots to Capture

**Screenshot 1.1 - GitHub Repository**
```bash
# URL: https://github.com/DimitriDondoladze/DevOps_Final

# Include in screenshot:
- Repository name and description
- Files: app/, terraform/, .github/, README.md
- Branch: main
```

**Screenshot 1.2 - Application Code (app.py)**
```bash
# File: app/app.py

# Include in screenshot:
- Flask routes: @app.route("/")
- Database connection: @app.route("/db")
- Environment variables being used
```

**Screenshot 1.3 - Requirements.txt**
```bash
# File: app/requirements.txt

# Should show:
flask
pymysql
```

### 📝 Explanation to Write

```markdown
## Task 1: Application and Repository Setup

### GitHub Repository
- Repository: https://github.com/DimitriDondoladze/DevOps_Final
- Contains complete Flask application with database connectivity
- Organized with app/, terraform/, and .github/ directories

### Application Functionality
The Flask application (app.py) provides:
1. **Home endpoint** (/) - Health check returning "Hello from AWS DevOps Final Project"
2. **Database check** (/db) - Tests MySQL connectivity using environment variables
3. **Environment Variables** - Uses DB_HOST, DB_NAME, DB_USER, DB_PASSWORD

### Technology Stack
- Python 3.9 (Flask framework)
- PyMySQL for database driver
- Dockerfile for containerization
- Requirements.txt for dependency management
```

---

## Task 2: Database Setup with Amazon RDS (5 pts)

### ✅ Deliverables

**Submit:**
- Terraform RDS code OR AWS Console screenshot
- Security group configuration (code or screenshot)
- Database connectivity explanation

### 📸 Screenshots to Capture

**Screenshot 2.1 - Terraform RDS Module**
```bash
# File: terraform/modules/rds/main.tf

# Include:
- aws_db_instance resource
- engine = "mysql"
- database_name, username, password
- db_subnet_group_name
- vpc_security_group_ids
```

**Screenshot 2.2 - Terraform Variables for RDS**
```bash
# File: terraform/terraform.tfvars

# Include:
rds_instance_class = "db.t3.micro"
database_name = "appdb"
database_user = "admin"
database_password = "ChangeMe@12345"
rds_publicly_accessible = true
```

**Screenshot 2.3 - AWS RDS Instance (from AWS Console)**
```bash
# AWS Console → RDS → Databases

# Include:
- DB identifier: devops-final-db
- Engine: MySQL 8.0.35
- Status: Available
- Endpoint: devops-final-db.xxxxx.us-west-2.rds.amazonaws.com
- Allocated storage: 20 GB
```

**Screenshot 2.4 - Security Group Configuration**
```bash
# File: terraform/modules/security-groups/main.tf OR AWS Console

# Include:
- Inbound rule: Port 3306 (MySQL)
- Source: ECS security group (devops-final-ecs-tasks-sg)
- Outbound: Allow all
```

### 📝 Explanation to Write

```markdown
## Task 2: Database Setup with Amazon RDS

### RDS Configuration
- **Engine**: MySQL 8.0.35
- **Instance Class**: db.t3.micro (cost-optimized)
- **Storage**: 20 GB
- **Location**: Private subnets (10.0.10.0/24, 10.0.11.0/24)
- **Database Name**: appdb
- **Master User**: admin

### Networking Configuration
- **Deployment**: Private subnets (not publicly routable)
- **Public Accessible**: Enabled for troubleshooting
- **Availability Zones**: Multi-AZ capable across us-west-2a and us-west-2b

### Security Configuration
- **Security Group**: Inbound MySQL (3306) from ECS tasks only
- **Network Isolation**: Via security group rules
- **Database Credentials**: Provided via environment variables to ECS tasks
- **Encrypted Storage**: Enabled

### Connectivity Flow
1. Flask application runs in ECS task
2. ECS task has access to RDS security group
3. RDS accepts connections from ECS security group on port 3306
4. Database credentials injected as environment variables
5. Connection string: mysql://admin:password@devops-final-db.xxxxx.us-west-2.rds.amazonaws.com:3306/appdb
```

---

## Task 3: Containerization and Image Registry (5 pts)

### ✅ Deliverables

**Submit:**
- Dockerfile source code
- ECR repository screenshot with pushed image
- Container build process explanation

### 📸 Screenshots to Capture

**Screenshot 3.1 - Dockerfile**
```bash
# File: app/Dockerfile

# Include:
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

**Screenshot 3.2 - ECR Module (Terraform)**
```bash
# File: terraform/modules/ecr/main.tf

# Include:
- aws_ecr_repository resource
- repository_name = "devops-final"
- scan_on_push = true
- Lifecycle policy (keep last 5 images)
```

**Screenshot 3.3 - ECR Repository in AWS Console**
```bash
# AWS Console → ECR → Repositories

# Include:
- Repository name: devops-final
- Images pushed: Show latest image with SHA tag
- Push commands (if available)
- Image scan results
```

**Screenshot 3.4 - ECR Image Details**
```bash
# AWS Console → ECR → devops-final → Pushed images

# Include:
- Image tag: (SHA hash from GitHub Actions)
- Image size: ~500MB
- Scan status: "Complete" or "Passed"
- Push date/time
```

### 📝 Explanation to Write

```markdown
## Task 3: Containerization and Image Registry

### Docker Configuration
**Dockerfile Strategy**:
- Base image: python:3.9-slim (lightweight, ~150MB)
- Working directory: /app
- Dependencies: Installed via pip using requirements.txt
- Exposed port: 5000 (Flask default)
- Entry point: python app.py

**Optimization**:
- Slim image reduces size and attack surface
- Requirements cached in layer for faster rebuilds
- Single CMD entry point for clear container purpose

### ECR Repository Setup
- **Repository Name**: devops-final
- **Region**: us-west-2
- **Lifecycle Policy**: Keep last 5 images (cost optimization)
- **Image Scanning**: Enabled for vulnerability detection

### Build Process
1. GitHub Actions triggered on push to main
2. Docker image built: `docker build -t ECR_URL/devops-final:SHA ./app`
3. Image pushed to ECR: `docker push ECR_URL/devops-final:SHA`
4. Terraform updated with new image URI
5. ECS service automatically uses latest image

### Image Registry Security
- Private repository (not publicly accessible)
- Images scanned for vulnerabilities
- Access controlled via IAM policies
- Only ECS tasks can pull images
```

---

## Task 4: CI/CD Pipeline with GitHub Actions (5 pts)

### ✅ Deliverables

**Submit:**
- GitHub Actions workflow YAML code
- Successful pipeline run screenshot
- Pipeline stages explanation

### 📸 Screenshots to Capture

**Screenshot 4.1 - Workflow File**
```bash
# File: .github/workflows/deploy.yml

# Include entire file in PDF
```

**Screenshot 4.2 - GitHub Actions Workflow Run**
```bash
# GitHub Repository → Actions → Latest workflow run

# Include:
- Workflow name: "Build and Deploy to ECS"
- Status: ✅ Success (green checkmark)
- Duration: Time taken
- Commit: Latest commit hash and message
```

**Screenshot 4.3 - Build Job Logs**
```bash
# Click "Build" stage

# Include:
- "Checkout repository" ✅
- "Configure AWS credentials" ✅
- "Login to Amazon ECR" ✅
- "Build, tag, and push image" ✅ (show image URI)
```

**Screenshot 4.4 - Deploy Job Logs**
```bash
# Click "Deploy" stage

# Include:
- "Checkout repository" ✅
- "Configure AWS credentials" ✅
- "Terraform Init" ✅
- "Terraform Plan" ✅
- "Terraform Apply" ✅
```

**Screenshot 4.5 - Deployment Summary**
```bash
# Click "Notify" stage

# Include:
- Deployment Status summary
- Build Status: Success
- Deploy Status: Success
- Commit and branch information
```

### 📝 Explanation to Write

```markdown
## Task 4: CI/CD Pipeline with GitHub Actions

### Pipeline Architecture
**Trigger**: Automatic on push to main branch

**Three Main Stages**:

1. **Build Stage**
   - Checkout source code from GitHub
   - Configure AWS credentials (from GitHub Secrets)
   - Login to Amazon ECR
   - Build Docker image with GitHub commit SHA as tag
   - Push image to ECR repository
   - Output: Image URI for next stage

2. **Deploy Stage**
   - Download Terraform configuration
   - Initialize Terraform (terraform init)
   - Create deployment plan (terraform plan)
   - Pass container image URI to Terraform
   - Apply infrastructure changes (terraform apply)
   - Creates/updates: ECS service with new image

3. **Notify Stage**
   - Report deployment status
   - Generate summary in GitHub Actions UI
   - Show commit, branch, and results

### GitHub Secrets Configuration
Used for secure credential storage:
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key

### Environment Variables
```
AWS_REGION = us-west-2
ECR_REPOSITORY = devops-final
ECS_CLUSTER = devops-final-cluster
ECS_SERVICE = devops-final-service
```

### Pipeline Benefits
- **Automation**: No manual deployment steps
- **Consistency**: Same build process every time
- **Speed**: Deploys within minutes of code push
- **Traceability**: Each deployment linked to specific commit
- **Rollback**: Previous images still in ECR for quick rollback
```

---

## Task 5: Application Deployment on ECS (5 pts)

### ✅ Deliverables

**Submit:**
- ECS task definition OR deployment manifest
- Screenshot of running ECS tasks
- Application accessibility screenshot
- Deployment flow explanation

### 📸 Screenshots to Capture

**Screenshot 5.1 - ECS Module (Task Definition)**
```bash
# File: terraform/modules/ecs/main.tf (first 100 lines)

# Include:
- aws_ecs_task_definition resource
- container_definitions (image, ports, environment variables)
- execution_role_arn and task_role_arn
- network_mode = "awsvpc"
- cpu = "256"
- memory = "512"
```

**Screenshot 5.2 - ECS Service Configuration**
```bash
# File: terraform/modules/ecs/main.tf (continuation)

# Include:
- aws_ecs_service resource
- launch_type = "FARGATE"
- network_configuration (subnets, security groups)
- load_balancer configuration (ALB attachment)
- desired_count = 2
```

**Screenshot 5.3 - ECS Cluster in AWS Console**
```bash
# AWS Console → ECS → Clusters → devops-final-cluster

# Include:
- Cluster name: devops-final-cluster
- Status: Active
- Services: devops-final-service
- Task count: 2 (or your desired count)
```

**Screenshot 5.4 - ECS Service Status**
```bash
# AWS Console → ECS → Clusters → devops-final-cluster → Services → devops-final-service

# Include:
- Service name: devops-final-service
- Desired count: 2
- Running count: 2
- Status: ACTIVE
- Task definition: devops-final:1 (or latest revision)
```

**Screenshot 5.5 - Running ECS Tasks**
```bash
# AWS Console → ECS → Clusters → devops-final-cluster → Tasks

# Include:
- Task 1 status: RUNNING
- Task 2 status: RUNNING
- CPU/Memory allocated
- Network interface details
- Launch type: FARGATE
```

**Screenshot 5.6 - Application Running**
```bash
# Browser: http://<ALB_DNS_NAME>/

# Include:
- URL in address bar
- Response: "Hello from AWS DevOps Final Project"
- HTTP 200 status (can check browser dev tools)
```

**Screenshot 5.7 - Database Connectivity Test**
```bash
# Browser: http://<ALB_DNS_NAME>/db

# Include:
- URL: /db endpoint
- Response: {"status": "success", "db_response": 1}
- HTTP 200 status
```

**Screenshot 5.8 - Auto Scaling Configuration**
```bash
# File: terraform/modules/ecs/main.tf (auto-scaling section)

# Include:
- aws_appautoscaling_target (min 1, max 4)
- aws_appautoscaling_policy_cpu (target 70%)
- aws_appautoscaling_policy_memory (target 80%)
```

### 📝 Explanation to Write

```markdown
## Task 5: Application Deployment on ECS

### ECS Cluster Configuration
- **Cluster Name**: devops-final-cluster
- **Orchestration Type**: Fargate (serverless)
- **Region**: us-west-2 (2 AZs for HA)
- **Container Insights**: Enabled for monitoring

### ECS Service Configuration
- **Service Name**: devops-final-service
- **Launch Type**: FARGATE
- **Task Definition**: devops-final (latest)
- **Desired Count**: 2 tasks running
- **Load Balancer**: Application Load Balancer
- **Network**: Private subnets (10.0.10.0/24, 10.0.11.0/24)

### Task Definition Details
- **CPU**: 256 units (0.25 vCPU)
- **Memory**: 512 MB
- **Container Image**: ECR image (updated by GitHub Actions)
- **Container Port**: 5000
- **Environment Variables**:
  - FLASK_ENV = production
  - DB_HOST = RDS endpoint
  - DB_PORT = 3306
  - DB_NAME = appdb
  - DB_USER = admin
  - DB_PASSWORD = (from terraform.tfvars)

### Auto Scaling Configuration
- **Minimum Tasks**: 1
- **Desired Tasks**: 2
- **Maximum Tasks**: 4
- **CPU Target**: 70% (scales up if exceeded)
- **Memory Target**: 80% (scales up if exceeded)
- **Scaling Actions**: Automatic based on CloudWatch metrics

### Load Balancer Integration
- **ALB**: devops-final-alb
- **Target Group**: devops-final-tg
- **Health Check**:
  - Path: /
  - Interval: 30 seconds
  - Timeout: 3 seconds
  - Healthy threshold: 2
  - Unhealthy threshold: 2

### Networking & Security
- **Deployment**: Private subnets (no direct internet access)
- **Outbound**: Via NAT Gateway in public subnet
- **Inbound**: Only from ALB security group (port 5000)
- **Database Access**: Via security group rules (port 3306)

### Deployment Flow
1. GitHub Actions builds Docker image
2. Image pushed to ECR
3. Terraform updates task definition with new image
4. ECS creates new tasks with updated definition
5. ALB health checks new tasks
6. Tasks marked RUNNING when healthy
7. Previous tasks stopped gracefully
8. Application available via ALB DNS name
```

---

## Task 6: Monitoring, Cleanup, and Cost Control (5 pts)

### ✅ Deliverables

**Submit:**
- CloudWatch logs/monitoring screenshot
- Terraform destroy output OR cleanup explanation
- Cleanup verification screenshot
- Monitoring & cost control explanation

### 📸 Screenshots to Capture

**Screenshot 6.1 - CloudWatch Log Group**
```bash
# AWS Console → CloudWatch → Log groups

# Include:
- Log group: /ecs/devops-final
- Last event time
- Data retention: 7 days
```

**Screenshot 6.2 - CloudWatch Logs (Actual Logs)**
```bash
# AWS Console → CloudWatch → Log groups → /ecs/devops-final

# Include:
- Log stream: ecs/devops-final/container_name/xxx
- Timestamps
- Log entries from application startup and requests
- No errors visible
```

**Screenshot 6.3 - CloudWatch Metrics**
```bash
# AWS Console → CloudWatch → Metrics → ECS

# Include:
- CPUUtilization graph
- MemoryUtilization graph
- Request count
- Task count over time
```

**Screenshot 6.4 - Container Insights**
```bash
# AWS Console → CloudWatch → Container Insights → Clusters

# Include:
- Cluster: devops-final-cluster
- Task count: 2
- CPU/Memory utilization
- Service health
```

**Screenshot 6.5 - RDS Monitoring**
```bash
# AWS Console → RDS → devops-final-db → Monitoring

# Include:
- CPU utilization
- Database connections
- Storage used
- IOPS
```

**Screenshot 6.6 - ALB Metrics**
```bash
# AWS Console → EC2 → Load Balancers → devops-final-alb → Monitoring

# Include:
- Request count
- Target response time
- HTTP 200 responses
- Active connections
```

**Screenshot 6.7 - Cost Explorer (Optional)**
```bash
# AWS Console → Cost Explorer

# Include:
- Estimated charges for resources
- Service breakdown
- Monthly forecast
```

**Screenshot 6.8 - Terraform Destroy Plan**
```bash
# Terminal output: terraform destroy

# Include:
```
aws_ecs_service.app
aws_ecs_cluster.main
aws_rds_db_instance.main
aws_ecr_repository.app
aws_lb.main
aws_vpc.main
aws_nat_gateway.main
(and all related resources)

Plan: 0 to add, 0 to change, 100 to destroy.
```
```

**Screenshot 6.9 - Cleanup Verification**
```bash
# AWS Console after destroy completes

# Include:
- ECS: No clusters or services
- RDS: No database instances
- ECR: Repository deleted (or no images)
- VPC: Custom VPC deleted
- ALB: No load balancers
- CloudWatch: No new logs
```

**Screenshot 6.10 - Final State Verification**
```bash
# Terminal: terraform show (after destroy)

# Include:
# (Empty or showing removed resources)
```

### 📝 Explanation to Write

```markdown
## Task 6: Monitoring, Cleanup, and Cost Control

### Monitoring Architecture

#### CloudWatch Logs
- **Log Group**: /ecs/devops-final
- **Retention**: 7 days (auto-delete old logs)
- **Log Streams**: One per ECS task container
- **Log Format**: JSON with timestamps
- **Searchable**: Can search by keywords, timestamps, patterns

#### CloudWatch Metrics
- **ECS Metrics**:
  - CPUUtilization (%) - tracks CPU usage
  - MemoryUtilization (%) - tracks memory consumption
  - DesiredTaskCount - desired running tasks
  - RunningTaskCount - actual running tasks

- **ALB Metrics**:
  - RequestCount - number of requests
  - TargetResponseTime - latency
  - HTTPCode_Target_2XX_Count - successful requests
  - HTTPCode_Target_5XX_Count - server errors
  - HealthyHostCount - healthy targets
  - UnHealthyHostCount - unhealthy targets

- **RDS Metrics**:
  - CPUUtilization
  - DatabaseConnections - active connections
  - FreeableMemory
  - DiskQueueDepth

#### Container Insights
- **Cluster-level dashboards**: Aggregate view of all services
- **Service-level metrics**: Performance of specific service
- **Task-level logs**: Individual task troubleshooting
- **Real-time monitoring**: Updates every 15-30 seconds

### Auto Scaling for Cost Control
- **Scale-down**: Minimum 1 task (saves on compute)
- **Scale-up**: Maximum 4 tasks (prevents runaway costs)
- **CPU-based**: Scales when CPU > 70%
- **Memory-based**: Scales when memory > 80%
- **Reduces costs**: Tasks only run when needed

### Cost Optimization Strategies
1. **Right-sized instances**:
   - ECS: 256 CPU, 512 MB (smallest Fargate size)
   - RDS: db.t3.micro (free tier eligible)
   
2. **Lifecycle policies**:
   - ECR: Keep only last 5 images (not all)
   - Delete old Terraform state backups

3. **Resource cleanup**:
   - Destroy on daily basis during development
   - Enable auto-shutdown for development environments
   - Monitor AWS billing alerts

4. **Efficient architecture**:
   - NAT Gateway: Shared across availability zones
   - Private subnets: No direct internet costs
   - On-demand pricing: No reserved instances needed

### Cleanup Process

**Step 1: Destroy Terraform Infrastructure**
```bash
cd terraform
terraform destroy
# Removes: VPC, Subnets, NAT Gateway, RDS, ECS, ALB, ECR, IAM roles, Security groups
# Time: 5-10 minutes
```

**Step 2: Verify Deletion**
- AWS Console checks show no resources
- Terraform state shows empty
- CloudWatch shows no new logs

**Step 3: Manual Cleanup (if needed)**
- Delete IAM user created for GitHub Actions
- Delete S3 state bucket (if using remote state)
- Delete CloudWatch log groups (auto-deleted if no logs in 30 days)

### Cost Breakdown (Monthly Estimate)
```
ECS Fargate:        ~$15-20 (0.25 vCPU, 512 MB × 2 tasks)
RDS db.t3.micro:    ~$10-15 (20 GB storage, minimal I/O)
NAT Gateway:        ~$5 (per hour × hours running)
ALB:                ~$15 (per hour)
Data transfer:      ~$5 (minimal inter-AZ traffic)
Total:              ~$50-75/month (if running 24/7)
```

### Production Recommendations
1. **Enhanced Monitoring**: Enable detailed CloudWatch metrics
2. **Alerts**: Set up SNS notifications for anomalies
3. **Logging**: Store logs in S3 for long-term analysis
4. **Budget Alerts**: Set AWS Budget alerts at $50/month
5. **Regular Reviews**: Check costs weekly during active development
6. **Backup Strategy**: Enable RDS automated backups
7. **Disaster Recovery**: Document manual recovery procedures
```

---

## Compilation Checklist

Before submitting PDF, verify:

- [ ] **Task 1**: GitHub repo screenshot, app code, explanation
- [ ] **Task 2**: RDS Terraform code, security group rules, explanation
- [ ] **Task 3**: Dockerfile, ECR screenshot with images, explanation
- [ ] **Task 4**: GitHub Actions workflow YAML, successful run screenshot, explanation
- [ ] **Task 5**: ECS task definition, running tasks screenshot, app accessibility screenshot, explanation
- [ ] **Task 6**: CloudWatch logs screenshot, destroy output, cleanup verification, explanation

## PDF Compilation Steps

1. Gather all screenshots (PNG/JPEG)
2. Take Terraform code snippets (text)
3. Write explanations for each task
4. Organize in PDF (one section per task)
5. Name file: `DevOps_Final_YourName.pdf`
6. Submit to instructor

## Document Quality Checklist

- [ ] All screenshots are readable (not too small)
- [ ] Code is properly formatted
- [ ] Explanations are 100-200 words each
- [ ] No personal information exposed (AWS account IDs can stay, credentials removed)
- [ ] File is under 25 MB
- [ ] All 6 tasks represented
- [ ] Resource names match throughout document

---

**Ready to submit?** Ensure all checklist items are complete!
