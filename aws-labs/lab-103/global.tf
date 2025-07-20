provider "aws" {
 region = var.region
}

variable "region" {
 default = "us-east-1"
}

variable "ami" {
 default = "ami-0150ccaf51ab55a51"
 }

variable "vm_name" {
 default = "vm-philip"
}

variable "admin_username" {
 default = "admin-user"
}

variable "admin_password" {
 default = "Password123!"
}

variable "vm_size" {
 default = "t2.micro"
}

variable "vpc_name" {
 default = "philip_vpc"
}

variable "subnet_name" {
 default = "philip_subnet"
}


variable "Name" {
 default = "Philip"
}

