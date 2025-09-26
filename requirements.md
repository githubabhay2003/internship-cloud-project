# Prerequisites

To run and manage this project, the following tools and accounts are required on your local machine.

## Required Tools

- **Terraform (v1.13+)**: Used for provisioning the cloud infrastructure (EC2, Security Groups) on AWS.  
- **AWS CLI (v2+)**: Used for programmatic interaction with AWS services.  
- **Ansible (v2.16+)**: Used for configuration management to install Docker on the server. It is recommended to run Ansible from within the Windows Subsystem for Linux (WSL).  
- **Git**: Used for version control and interacting with the GitHub repository.  
- **SSH Client**: Used for securely connecting to the EC2 instance.  

## Required Accounts

- **AWS Account**: An active AWS account with programmatic access (Access Key ID and Secret Access Key) configured for the AWS CLI.  
- **GitHub Account**: To host the project's source code and trigger the Jenkins pipeline via webhooks.  
- **Docker Hub Account**: To store and pull the containerized application image.  
