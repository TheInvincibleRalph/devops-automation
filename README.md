# Project Documentation: Automated PHP App Deployment

**Author:** Raphael Adesegun

## Overview

I designed and deployed a production-ready CI/CD environment on AWS. My goal was to achieve full automation, moving from infrastructure provisioning to application deployment with zero manual steps.

## Architecture

* **Infrastructure:** I used **Terraform** to build a custom VPC with public and private subnets.
* **CI/CD:** I set up a **Jenkins** server on EC2 to orchestrate the pipeline.
* **Containerization:** The PHP application is containerized using **Docker** and stored in **Amazon ECR**.
* **Deployment:** I used **AWS SSM (Systems Manager)** to deploy the container to the application server.

---

## Architectural Diagram

![Architecture](Architecture.png)

---

## Design Decisions:

* **IAM Roles:** I attached IAM policies directly to the Jenkins EC2 instance. This is more secure because I don't have to store or manage static secret keys inside Jenkins.
* **AWS SSM for Deployment:** I used SSM to run deployment commands on the app server. This removed the need to manage SSH keys or open port 22 for Jenkins to communicate with the app server.
* **Java 21 for Jenkins:** I installed Java 21 (Amazon Corretto) to meet the latest Jenkins requirements and ensure environment stability.
* **Automated Security Scanning:** I integrated **Trivy** into the pipeline to scan every Docker image for high/critical vulnerabilities before pushing to the registry.

## How to Deploy

### 1. Infrastructure

Navigate to the Terraform directory and apply the configuration:

```bash
cd infra/environments/prod
terraform init
terraform apply -var-file="prod.tfvars"

```

### 2. CI/CD Setup

* Log into the Jenkins URL provided by the Terraform output.
* Install the **Git** and **Docker Pipeline** plugins.
* Create a Pipeline job pointing to this repository with the script path: `ci-cd/Jenkinsfile`.

### 3. Application Deployment

* Run the Jenkins job.
* The pipeline builds the image, scans it, pushes it to ECR, and uses SSM to pull and run the container on the target EC2.

## Assumptions & Limitations

* **Security:** The application currently runs on HTTP (Port 80). For a real production environment, I would add an SSL certificate and a Load Balancer.
* **State Management:** Terraform state is stored locally for this challenge. In a team environment, I would use an S3 backend with DynamoDB locking.

## Conclusion

The environment is fully automated. Any code change pushed to GitHub can be deployed to AWS with a single click in Jenkins, ensuring a repeatable and reliable release process.