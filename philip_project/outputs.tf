output "vm_public_ip" {
  value = azurerm_public_ip.pip-Philip.ip_address
  depends_on  = [null_resource.check_public_ip] 
  description = "Public IP address of the VM"
}

