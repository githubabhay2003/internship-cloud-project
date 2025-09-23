# Automated Web Application Deployment on AWS

**Internship Task Submission for NullClass Edtech Pvt. Ltd.**

---
## 1. Project Objective
The primary objective of this project was to design, build, and deploy a fully automated Continuous Integration and Continuous Deployment (CI/CD) pipeline. The goal was to take a static web application from a source code repository to a live, publicly accessible server on AWS, with the entire process being automated and triggered by a `git push`.  

The project implemented modern DevOps principles such as **Infrastructure as Code**, **Configuration Management**, and **Pipeline as Code**.

---

## 2. Core Technologies Used
- **Cloud Provider:** Amazon Web Services (AWS)  
- **Infrastructure as Code:** Terraform  
- **Configuration Management:** Ansible  
- **Containerization:** Docker & Docker Compose  
- **CI/CD Automation:** Jenkins  
- **Version Control:** Git & GitHub  

---

## 3. Implementation Report

### Task 1: Ansible for Configuration Management
**Task Description:**  
Write an Ansible playbook to install Docker, pull the application image, and run the container automatically on the server.

**Implementation Steps:**
1. Created an Ansible inventory file (`inventory.ini`) to define the target EC2 server's IP address and SSH connection details.  
2. Wrote an Ansible playbook (`playbook.yml`) to automate server configuration.  
3. Decided to use Ansible only for initial server setup (installing Docker). The image pull and container run steps were assigned to the Jenkins pipeline for a clear separation between server configuration and application deployment.  
4. Made the playbook idempotent and added tasks to install Docker prerequisites, add its GPG key and repository, and install Docker Engine and Docker Compose plugin.  

**Challenges & Solutions:**
- **Challenge:** Initial connection from Ansible failed with `UNPROTECTED PRIVATE KEY FILE!` error.  
  **Solution:** Moved the SSH key into WSL’s native Linux filesystem (`~/.ssh/`), applied correct permissions with `chmod 600`, and updated the inventory file.  

- **Challenge:** `docker-compose-plugin` package not found in Ubuntu’s default repositories.  
  **Solution:** Enhanced the playbook to follow Docker’s official installation guide by adding tasks for prerequisites, GPG key, and repository setup before installation.  

---

### Task 2: Terraform to Create EC2 Infrastructure
**Task Description:**  
Write Terraform scripts to launch an EC2 instance, open ports 80 and 22, and install Docker using `user_data` or SSH.

**Implementation Steps:**
1. Created a Terraform configuration file (`main.tf`) to define infrastructure as code.  
2. Defined an `aws_instance` resource to launch a `t3.micro` EC2 instance with Ubuntu 22.04 LTS AMI.  
3. Created an `aws_security_group` resource with ingress rules for SSH (22) and HTTP (80).  
4. Chose Ansible (instead of Terraform `user_data`) for Docker installation, to keep a clear separation between provisioning (Terraform) and configuration (Ansible).  

**Challenges & Solutions:**
- **Challenge:** `terraform apply` failed because `t2.micro` was not Free Tier eligible in `ap-south-1`.  
  **Solution:** Updated the instance type to `t3.micro`.  

- **Challenge:** Git push failed due to `.terraform` directory and private SSH key being included, causing "Large file detected" and security risk.  
  **Solution:** Added a `.gitignore` to exclude state files, temp directories, and keys. Undid incorrect commit with `git reset` and pushed a clean commit.  

---

### Task 3: Docker Compose for Multi-Environment
**Task Description:**  
Create a `docker-compose.yml` file to run an Nginx static site and optionally add a container like Watchtower.

**Implementation Steps:**
1. Created a `Dockerfile` using Nginx base image to serve the static website.  
2. Wrote a `docker-compose.yml` defining a `webapp` service, mapping port 80, and setting a restart policy of `always`.  
3. Decided not to use Watchtower. Jenkins pipeline already provides a push-based deployment model, making Watchtower redundant. This keeps Jenkins as the single orchestrator for deployments.  

**Challenges & Solutions:**
- This task was foundational and did not present direct challenges.  

---

### Task 4: Add Webhook Integration
**Task Description:**  
Connect GitHub with Jenkins via a webhook to trigger the Jenkins job automatically on a code push.

**Implementation Steps:**
1. Configured the Jenkins pipeline job by enabling **"GitHub hook trigger for GITScm polling"** in the "Build Triggers" section.  
2. In GitHub repository settings, created a new webhook. The **Payload URL** was set to the Jenkins server’s public IP with the `/github-webhook/` endpoint (`http://<IP>:8080/github-webhook/`). Content type was set to `application/json`.  
3. Tested the integration by updating `index.html` and pushing the change. The webhook successfully triggered a new Jenkins build automatically.  

**Challenges & Solutions:**
- **Challenge:** Git push failed with a `(fetch first)` error, indicating remote changes not present locally.  
  **Solution:** Ran `git pull origin main` to merge remote changes, after which the `git push` completed successfully.  

---

### Task 5: Deploy to EC2 Instance
**Task Description:**  
SSH into an EC2 instance, pull the Docker image from Docker Hub, and run the container on port 80.

**Implementation Steps:**
1. Automated this entire task as the final **"Deploy to EC2"** stage in the `Jenkinsfile`.  
2. Used the **sshagent plugin** to securely handle SSH credentials and connect to the EC2 server as the `ubuntu` user.  
3. Deployment script ensured robustness by creating `/home/ubuntu/app`, setting correct ownership, and cloning the GitHub repository.  
4. Executed `docker compose pull` to fetch the latest image from Docker Hub and `docker compose up -d` to start the container in detached mode, exposing port 80.  

**Challenges & Solutions:**
- **Challenge:** Deployment script failed with `Permission denied` because `/home/ubuntu/app` didn’t exist and permissions were incorrect.  
  **Solution:** Updated Jenkinsfile script to use `sudo mkdir -p` and `sudo chown` to fix directory creation and ownership issues.  

---

### Task 6: Configure Jenkins Pipeline
**Task Description:**  
Create a declarative Jenkinsfile that pulls code from GitHub, builds a Docker image, and pushes it to Docker Hub.

**Implementation Steps:**
1. Wrote a declarative `Jenkinsfile` with a multi-stage structure: **Checkout, Build, Login, Push, Deploy**.  
2. Used Jenkins Credentials Manager to securely handle Docker Hub credentials and the EC2 SSH key.  
3. Configured pipeline to build a uniquely tagged Docker image per run (`${BUILD_NUMBER}`) and also tag it as `:latest`.  

**Challenges & Solutions:**
- **Challenge:** Build failed with a `Docker permission denied` error on the server’s Docker socket.  
  **Solution:** Added the `jenkins` user to the `docker` group (`sudo usermod -aG docker jenkins`) and restarted Jenkins.  

- **Challenge:** Docker Hub image push was denied.  
  **Solution:** Corrected namespace mismatch by updating `DOCKER_IMAGE_NAME` in `Jenkinsfile` to use personal Docker Hub username (`abhaydocker732/internship-project`).  

- **Challenge:** Pipeline failed with `No such DSL method 'sshagent'` error.  
  **Solution:** Installed the missing **SSH Agent** plugin via Jenkins Plugin Manager.  

---

## 🎥 Project Demo
[Watch the demo video](https://drive.google.com/file/d/1boezQtv-9o_LGoYgfXfqK7JumYTg2vOi/view?usp=sharing)  

This video showcases the **end-to-end CI/CD pipeline** in action:  
- A local code change is pushed to GitHub.  
- The GitHub webhook triggers Jenkins.  
- Jenkins builds a new Docker image, pushes it to Docker Hub, and deploys it to the AWS EC2 server.  
- The new version is live on the public site within moments, with **zero manual intervention**.  

---

## ✅ Project Outcomes
- **Terraform** for Infrastructure as Code  
- **Ansible** for server configuration  
- **Jenkinsfile** for Pipeline as Code  
- Fully automated CI/CD pipeline from code commit to live deployment on AWS  

---

## Author
**Abhay Kumar Saini**  
