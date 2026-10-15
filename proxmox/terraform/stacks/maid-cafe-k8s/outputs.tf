output "vm_ids" {
  description = "Current Proxmox guest IDs by VMID (vm_ids)."
  value = {
    "101" = proxmox_virtual_environment_vm.vm_101.id
    "102" = proxmox_virtual_environment_vm.vm_102.id
    "104" = proxmox_virtual_environment_vm.vm_104.id
    "105" = proxmox_virtual_environment_vm.vm_105.id
    "106" = proxmox_virtual_environment_vm.vm_106.id
    "107" = proxmox_virtual_environment_vm.vm_107.id
    "108" = proxmox_virtual_environment_vm.vm_108.id
    "109" = proxmox_virtual_environment_vm.vm_109.id
    "110" = proxmox_virtual_environment_vm.vm_110.id
    "111" = proxmox_virtual_environment_vm.vm_111.id
    "112" = proxmox_virtual_environment_vm.vm_112.id
    "113" = proxmox_virtual_environment_vm.vm_113.id
    "115" = proxmox_virtual_environment_vm.vm_115.id
    "116" = proxmox_virtual_environment_vm.vm_116.id
    "127" = proxmox_virtual_environment_vm.vm_127.id
    "128" = proxmox_virtual_environment_vm.vm_128.id
    "129" = proxmox_virtual_environment_vm.vm_129.id
    "132" = proxmox_virtual_environment_vm.vm_132.id
    "133" = proxmox_virtual_environment_vm.vm_133.id
    "134" = proxmox_virtual_environment_vm.vm_134.id
    "135" = proxmox_virtual_environment_vm.vm_135.id
    "136" = proxmox_virtual_environment_vm.vm_136.id
    "137" = proxmox_virtual_environment_vm.vm_137.id
    "138" = proxmox_virtual_environment_vm.vm_138.id
    "139" = proxmox_virtual_environment_vm.vm_139.id
    "140" = proxmox_virtual_environment_vm.vm_140.id
    "141" = proxmox_virtual_environment_vm.vm_141.id
    "142" = proxmox_virtual_environment_vm.vm_142.id
    "143" = proxmox_virtual_environment_vm.vm_143.id
    "144" = proxmox_virtual_environment_vm.vm_144.id
    "168" = proxmox_virtual_environment_vm.k8s_01.id
  }
}

output "container_ids" {
  description = "Current Proxmox guest IDs by VMID (container_ids)."
  value = {
    "100" = proxmox_virtual_environment_container.ct_100.id
    "103" = proxmox_virtual_environment_container.ct_103.id
    "114" = proxmox_virtual_environment_container.ct_114.id
    "117" = proxmox_virtual_environment_container.ct_117.id
    "118" = proxmox_virtual_environment_container.ct_118.id
    "119" = proxmox_virtual_environment_container.ct_119.id
    "120" = proxmox_virtual_environment_container.ct_120.id
    "121" = proxmox_virtual_environment_container.ct_121.id
    "122" = proxmox_virtual_environment_container.ct_122.id
    "123" = proxmox_virtual_environment_container.ct_123.id
    "124" = proxmox_virtual_environment_container.ct_124.id
    "125" = proxmox_virtual_environment_container.ct_125.id
    "126" = proxmox_virtual_environment_container.ct_126.id
    "130" = proxmox_virtual_environment_container.ct_130.id
    "131" = proxmox_virtual_environment_container.ct_131.id
    "167" = proxmox_virtual_environment_container.ct_167.id
  }
}
