# Define the provider and global variables
provider "azurerm" {
  features {}
}

variable "yourname" {
  default     = "Philip"
  description = "Change it to your first name and the first letter of your family name: ex. yanivc - for yaniv cohen"
}

variable "vm_name" {
  default     = "vm-Philip"
  description = "Change it to your first name and the first letter of your family name: ex. yanivc - for yaniv cohen"
}

variable "admin_username" {
  default     = "adminuser"
  description = "Username for the admin user on the VM"
}

variable "admin_password" {
  default     = "Password123!"
  description = "Password for the admin user on the VM"
}

variable "location" {
  default     = "us-east-1"
  description = "awsregion where resources will be deployed"
}

variable "vm_size" {
  default     = "Standard_B1ms"
  description = "Size of the virtual machine"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.yourname}"
  location = var.location
}
