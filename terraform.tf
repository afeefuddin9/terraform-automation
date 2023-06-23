#Innitialization Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

#Configuring Existing VPC
resource "aws_vpc" "playground-vpc-vpc" {
  cidr_block = "10.29.0.0/16"

  tags = {
    Name = "playground-vpc-vpc"
  }
}

#Running provided services which is AWS
provider "aws" {
    region = "ap-south-1"
}


#Confuguring Security Group
resource "aws_security_group" "instance_security_group" {
  name        = "instance-security-group"
  description = "Security group for the EC2 instance"
  vpc_id = aws_vpc.playground-vpc-vpc.id

 # vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update with appropriate source IP ranges
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description ="worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add any additional ingress rules you require
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Selecting the AMI for the Instance
data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}  


# Defining Instance Confuguring
resource "aws_instance" "terraform-auto-instance" {
  count                  = 2
  ami           = data.aws_ami.amazon-2.id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  subnet_id = "subnet-0a4c6f267b88e94d7"
  key_name = "terraform-key"
  associate_public_ip_address = true
 
  tags = {
    Name = "Terraform-instance-box-1"
  }
}

# Post instance launch output
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.terraform-auto-instance
  #value       = aws_instance.terraform-auto-instance.public_ip
}