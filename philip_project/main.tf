provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg-Philip" {
  name     = "Philip-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-Philip" {
  name                = "Philip-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-Philip.name
}


resource "azurerm_subnet" "subnet-Philip" {
  name                 = "Philip-subnet"
  resource_group_name  = azurerm_resource_group.rg-Philip.name
  virtual_network_name = azurerm_virtual_network.vnet-Philip.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "pip-Philip" {
  name                = "Philip-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-Philip.name
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}


resource "azurerm_network_interface" "nic-Philip" {
  name                = "Philip-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-Philip.name

  ip_configuration {
    name                          = "Philip-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-Philip.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-Philip.id
  }
}


resource "azurerm_linux_virtual_machine" "vm-Philip" {
  name                  = "Philip-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-Philip.name
  network_interface_ids = [azurerm_network_interface.nic-Philip.id]
  size                  = var.vm_size

  os_disk {
    name              = "Philip-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "Philip-vm"
}

