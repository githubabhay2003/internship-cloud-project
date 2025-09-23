terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# 1. Create an SSH key pair resource
# This reads your public key file and uploads it to AWS.
resource "aws_key_pair" "internship_key" {
  key_name   = "internship-key"
  public_key = file("internship-key.pub")
}

# 2. Create a Security Group to act as a firewall
resource "aws_security_group" "web_sg" {
  name        = "website-sg"
  description = "Allow HTTP and SSH inbound traffic"

  # Allow incoming web traffic on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming SSH traffic on port 22 from anywhere
  # For better security, you could restrict this to your IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Website Security Group"
  }
}

# 3. Create the EC2 Instance (Virtual Server)
resource "aws_instance" "web_server" {
  # Ubuntu Server 22.04 LTS AMI for ap-south-1 region
  ami           = "ami-08e5424edfe926b43"
  
  # t3.micro is eligible for the AWS Free Tier
  instance_type = "t3.micro"

  # Associate our SSH key pair
  key_name      = aws_key_pair.internship_key.key_name

  # Associate our security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Internship Web Server"
  }
}