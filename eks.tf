eks-cluster/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── backend.tf


terraform.tfvars
===============
aws_region         = "ap-south-1"
cluster_name       = "eks-cluster-mumbai"
k8s_version        = "1.31"
node_instance_type = "t3.medium"
node_count         = 2
s3_bucket          = "your-s3-bucket-name"
s3_key             = "terraform/eks-cluster/terraform.tfstate"
dynamodb_table     = "terraform-lock-table"


backend.tf
===============
terraform {
  backend "s3" {
    bucket         = var.s3_bucket
    key            = var.s3_key
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table
    encrypt        = true
  }
}

variables.tf
============
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "s3_bucket" {
  description = "S3 bucket for remote state storage"
  type        = string
}

variable "s3_key" {
  description = "Path in the S3 bucket for the state file"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB table for state locking"
  type        = string
}


main.tf
=======
provider "aws" {
  region = var.aws_region
}

# Data block to fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data block to fetch subnets of the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data block to fetch the latest Amazon EKS-optimized AMI
data "aws_ami" "eks_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.k8s_version}*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["602401143452"] # Amazon EKS AMI owner ID
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.k8s_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count + 1
    min_size     = 1
  }

  instance_types = [var.node_instance_type]

  launch_template {
    id = aws_launch_template.eks_nodes.id
  }
}

# Launch Template for Node Group
resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.cluster_name}-lt"
  instance_type = var.node_instance_type

  image_id = data.aws_ami.eks_optimized.id

  user_data = base64encode(<<-EOT
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name}
  EOT
  )
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

# IAM Role for EKS Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

outputs.tf
=========
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "node_ami_id" {
  value = data.aws_ami.eks_optimized.id
}
===============



