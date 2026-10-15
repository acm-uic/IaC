# Adopt existing guests. These are imports, never clone/create instructions.
# IDs include the current node; resource types distinguish QEMU from LXC.

import {
  to = proxmox_virtual_environment_container.ct_100
  id = "boba/100"
}

import {
  to = proxmox_virtual_environment_vm.vm_101
  id = "boba/101"
}

import {
  to = proxmox_virtual_environment_vm.vm_102
  id = "coffee/102"
}

import {
  to = proxmox_virtual_environment_container.ct_103
  id = "boba/103"
}

import {
  to = proxmox_virtual_environment_vm.vm_104
  id = "coffee/104"
}

import {
  to = proxmox_virtual_environment_vm.vm_105
  id = "chai/105"
}

import {
  to = proxmox_virtual_environment_vm.vm_106
  id = "boba/106"
}

import {
  to = proxmox_virtual_environment_vm.vm_107
  id = "matcha/107"
}

import {
  to = proxmox_virtual_environment_vm.vm_108
  id = "matcha/108"
}

import {
  to = proxmox_virtual_environment_vm.vm_109
  id = "matcha/109"
}

import {
  to = proxmox_virtual_environment_vm.vm_110
  id = "boba/110"
}

import {
  to = proxmox_virtual_environment_vm.vm_111
  id = "matcha/111"
}

import {
  to = proxmox_virtual_environment_vm.vm_112
  id = "matcha/112"
}

import {
  to = proxmox_virtual_environment_vm.vm_113
  id = "matcha/113"
}

import {
  to = proxmox_virtual_environment_container.ct_114
  id = "chai/114"
}

import {
  to = proxmox_virtual_environment_vm.vm_115
  id = "chai/115"
}

import {
  to = proxmox_virtual_environment_vm.vm_116
  id = "chai/116"
}

import {
  to = proxmox_virtual_environment_container.ct_117
  id = "chai/117"
}

import {
  to = proxmox_virtual_environment_container.ct_118
  id = "chai/118"
}

import {
  to = proxmox_virtual_environment_container.ct_119
  id = "chai/119"
}

import {
  to = proxmox_virtual_environment_container.ct_120
  id = "coffee/120"
}

import {
  to = proxmox_virtual_environment_container.ct_121
  id = "coffee/121"
}

import {
  to = proxmox_virtual_environment_container.ct_122
  id = "boba/122"
}

import {
  to = proxmox_virtual_environment_container.ct_123
  id = "boba/123"
}

import {
  to = proxmox_virtual_environment_container.ct_124
  id = "coffee/124"
}

import {
  to = proxmox_virtual_environment_container.ct_125
  id = "boba/125"
}

import {
  to = proxmox_virtual_environment_container.ct_126
  id = "boba/126"
}

import {
  to = proxmox_virtual_environment_vm.vm_127
  id = "matcha/127"
}

import {
  to = proxmox_virtual_environment_vm.vm_128
  id = "chai/128"
}

import {
  to = proxmox_virtual_environment_vm.vm_129
  id = "chai/129"
}

import {
  to = proxmox_virtual_environment_container.ct_130
  id = "boba/130"
}

import {
  to = proxmox_virtual_environment_container.ct_131
  id = "boba/131"
}

import {
  to = proxmox_virtual_environment_vm.vm_132
  id = "matcha/132"
}

import {
  to = proxmox_virtual_environment_vm.vm_133
  id = "matcha/133"
}

import {
  to = proxmox_virtual_environment_vm.vm_134
  id = "matcha/134"
}

import {
  to = proxmox_virtual_environment_vm.vm_135
  id = "matcha/135"
}

import {
  to = proxmox_virtual_environment_vm.vm_136
  id = "matcha/136"
}

import {
  to = proxmox_virtual_environment_vm.vm_137
  id = "matcha/137"
}

import {
  to = proxmox_virtual_environment_vm.vm_138
  id = "matcha/138"
}

import {
  to = proxmox_virtual_environment_vm.vm_139
  id = "matcha/139"
}

import {
  to = proxmox_virtual_environment_vm.vm_140
  id = "matcha/140"
}

import {
  to = proxmox_virtual_environment_vm.vm_141
  id = "matcha/141"
}

import {
  to = proxmox_virtual_environment_vm.vm_142
  id = "matcha/142"
}

import {
  to = proxmox_virtual_environment_vm.vm_143
  id = "matcha/143"
}

import {
  to = proxmox_virtual_environment_vm.vm_144
  id = "boba/144"
}

import {
  to = proxmox_virtual_environment_container.ct_167
  id = "coffee/167"
}

# This legacy address points to taskbox-template (107), not a Kubernetes VM.
# Forget only its Terraform ownership; the VM is adopted above as vm_107.
removed {
  from = proxmox_vm_qemu.k8s_01

  lifecycle {
    destroy = false
  }
}

import {
  to = proxmox_haresource.bootc_builder
  id = "vm:110"
}
