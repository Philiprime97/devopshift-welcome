provider "aws" {
 region = "us-east-1"
}

#Configuring Variables
variable "create_vpc" {
  type    = bool
  default = true
}

variable "create_ec2" {
  type    = bool
  default = true
}


# Creating VPC
resource "aws_vpc" "custom_vpc" {
  count = var.create_vpc ? 1 : 0

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "custom-vpc"
  }
}

#Creating Subnet
resource "aws_subnet" "custom_subnet" {
  count = var.create_vpc ? 1 : 0

  vpc_id            = aws_vpc.custom_vpc[0].id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "custom-subnet"
  }
}

#Creating AWS_Instance
resource "aws_instance" "example" {
  count = var.create_ec2 ? 1 : 0

  ami           = "ami-0150ccaf51ab55a51" # Ubuntu AMI
  instance_type = "t2.micro"

  subnet_id = aws_subnet.custom_subnet[0].id

  tags = {
    Name = "example-ec2"
  }

  depends_on = [aws_vpc.custom_vpc]
}


#Output Values
output "vpc_id" {
  value       = var.create_vpc ? aws_vpc.custom_vpc[0].id : "VPC not created"
  description = "The ID of the custom VPC"
}

output "subnet_id" {
  value       = var.create_vpc ? aws_subnet.custom_subnet[0].id : "Subnet not created"
  description = "The ID of the custom subnet"
}