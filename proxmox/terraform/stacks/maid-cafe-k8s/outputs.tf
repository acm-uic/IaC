output "k8s-01_vm_id" {
  description = "The ID of the k8s-01 VM"
  value       = proxmox_vm_qemu.k8s_01.id
}

