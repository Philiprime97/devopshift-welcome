output "vm_public_ip" {
  value = azurerm_public_ip.pip-Philip.ip_address
  description = "Public IP address of the VM"
}

