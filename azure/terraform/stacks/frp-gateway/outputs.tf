output "public_addresses" {
  value = { for family, ip in azurerm_public_ip.gateway : family => ip.ip_address }
}
output "resource_group" {
  value = azurerm_resource_group.gateway.name
}
output "vm_id" {
  value = azurerm_linux_virtual_machine.gateway.id
}
output "nic_id" {
  value = azurerm_network_interface.gateway.id
}
output "security_group_id" {
  value = azurerm_network_security_group.gateway.id
}
