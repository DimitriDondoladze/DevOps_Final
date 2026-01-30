# DevOps Final Assessment – AWS Application Deployment

## Assessment Goal

Students must deploy a mini application to AWS using a fully managed cloud architecture.  
The deployment must use GitHub Actions for CI/CD, Amazon ECS or Amazon EKS for container orchestration, and Amazon RDS for the database.  

---

## Technology Stack

- GitHub Actions for CI/CD  
- Amazon ECS or Amazon EKS for application runtime  
- Amazon RDS for database  
- Amazon ECR for container images  
- Managed AWS services only  


---

## Task 1 — Application and Repository Setup (5 pts)

Instructions:  
- Create a GitHub repository for the application.  
- Include application source code and a README file.  

Submit:  
- Screenshot of GitHub repository OR Terraform code if applicable.  
- Screenshot of README file OR explanation of repository structure.  
- Short explanation describing application functionality.

---

## Task 2 — Database Setup with Amazon RDS (5 pts)

Instructions:  
- Create an Amazon RDS instance using MySQL or PostgreSQL.  
- Configure networking so ECS or EKS workloads can access the database.  
- Store database credentials securely using AWS or container secrets.

Submit:  
- Screenshot of RDS instance OR Terraform code defining RDS resources.  
- Screenshot of security group rules OR Terraform networking configuration.  
- Short explanation describing database connectivity and security.

---

## Task 3 — Containerization and Image Registry (5 pts)

Instructions:  
- Create a Dockerfile for the application.  
- Build the Docker image.  
- Push the image to Amazon ECR.

Submit:  
- Screenshot of Dockerfile OR Dockerfile source code.  
- Screenshot of ECR repository with pushed image OR Terraform ECR definition.  
- Short explanation describing the container build process.

---

## Task 4 — CI/CD Pipeline with GitHub Actions (5 pts)

Instructions:  
- Create a GitHub Actions workflow.  
- Pipeline must build the Docker image and push it to ECR.  
- Pipeline must deploy the application to ECS or EKS automatically.

Submit:  
- Screenshot of GitHub Actions workflow file OR workflow YAML code.  
- Screenshot of successful pipeline run OR pipeline logs.  
- Short explanation describing pipeline stages.

---

## Task 5 — Application Deployment on ECS or EKS (5 pts)

Instructions:  
- Deploy the application using Amazon ECS or Amazon EKS.  
- Configure environment variables and secrets properly.  
- Expose the application via ALB, Service, or Ingress.

Submit:  
- Screenshot of running ECS tasks or Kubernetes pods OR deployment manifests.  
- Screenshot showing application accessible via HTTP.  
- Short explanation describing the deployment flow.

---

## Task 6 — Monitoring, Cleanup, and Cost Control (5 pts)

Instructions:  
- Enable logging and basic monitoring for the application.  
- Identify where logs and metrics can be viewed in AWS.  
- Clean up all created AWS resources after validation.

Submit:  
- Screenshot of logs or monitoring view OR Terraform destroy plan explanation.  
- Screenshot showing removed or stopped AWS resources OR explanation of cleanup process.  
- Short explanation describing monitoring and cost control.

---

## Infrastructure as Code Option

Students may submit Terraform code instead of screenshots.  
Terraform resources must be clearly structured and commented.  
Explanations are mandatory even when Terraform is used.  
Terraform submissions must include a brief explanation of each major resource.

---

## Submission Rules

- Submit a single PDF file.  
- File name format: DevOps_Final_STUDENT_NAME.pdf  
- Screenshots or Terraform code must be readable.  
- Explanations must be written in your own words.
