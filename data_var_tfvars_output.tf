main.tf
-------
provider "aws" {
  region = "ap-south-1"
}

resource.tf
-----------
#data block is used to read already present resource in cloud.
data "aws_ami" "amazon-linux-3" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"] 
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#resource block is used to create resource in cloud
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon-linux-3.id
  instance_type = var.instance_type
  count         = var.insatance_count

  tags = {
    Name = "ProdServer"
  }
}
resource "aws_vpc" "mycustomnetwork" {
  cidr_block = var.cidr_range
}

variable.tf
-----------
#variable.tf file
#in variable.tf file we basically specifty the data type of the aragument value
variable "instance_type" {
  type = string
}

variable "insatance_count" {
  type = number
  default = "1"
}

variable "cidr_range" {
  type = string
}


terraform.tfvars
----------------
#terraform.tfvars 
#terraform.tfvars file me argument ki acutal value specify karte hai.
instance_type   = "t2.nano"
cidr_range      = "10.0.0.0/16"
insatance_count =  "2"

output.tf
#output block is used to read the information.
output "instance_public_ip" {
  value = aws_instance.web[*].public_ip
}

output "instance_private_ip" {
  value = aws_instance.web[*].private_ip
}


