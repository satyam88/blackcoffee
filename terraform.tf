Lab1
=========
provider "aws" {
  region = "ap-south-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}
============
resource "aws_instance" "myinstance" {
  ami             = "ami-0b99c7725b9484f9e"
  instance_type   = "t2.small"
  count           = "2"
  key_name        = "aws-2025"
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Fixed list issue
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Fixed list issue
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Fixed list issue
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}



resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "My Network"
    Environment = "Dev"
  }
}

=============
LAB2
=============
main.tf
======
provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}
====
resource "aws_instance" "dev-instance" {
  ami             = var.ami_id
  instance_type   = var.instance_size
  count           = var.instance_count
  key_name        = var.instance_key
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "My Network"
    Environment = "Dev"
  }
}
====
variable "ami_id" {
  type = string
}

variable "instance_size" {
  type    = string
}

variable "instance_count" {
  type = number
}
variable "instance_key" {
  type = string
}

variable "aws_region" {
  type = string
}
===

ami_id         = "ami-0b99c7725b9484f9e"
instance_count = 2
instance_size   = "t2.micro"
instance_key   = "aws-2025"
aws_region     = "ap-south-1"

===
output "instance_Private_ip_addr" {
  value = aws_instance.dev-instance[*].private_ip
}

output "instance_Public_ip_addr" {
  value = aws_instance.dev-instance[*].public_ip
}
