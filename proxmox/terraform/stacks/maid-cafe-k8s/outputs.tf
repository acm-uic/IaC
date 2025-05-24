output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_vm_qemu.maid_cafe_vm.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_vm_qemu.maid_cafe_vm.name
}

output "vm_ip" {
  description = "The IP address of the VM (if available)"
  value       = proxmox_vm_qemu.maid_cafe_vm.default_ipv4_address
}