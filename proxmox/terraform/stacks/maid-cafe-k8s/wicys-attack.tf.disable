locals {
  wicys_attack_macaddrs = [
    "BC:24:11:42:53:73",
    "BC:24:11:93:AE:54",
    "BC:24:11:CB:CC:1E",
    "BC:24:11:E7:2F:8F",
    "BC:24:11:52:49:16",
    "BC:24:11:75:59:8E",
    "BC:24:11:84:86:10",
    "BC:24:11:1F:8B:30",
    "BC:24:11:7B:20:E4",
    "BC:24:11:36:B5:AC",
    "BC:24:11:EB:11:C4",
    "BC:24:11:4D:9A:00",
    "BC:24:11:43:1F:2B",
    "BC:24:11:3A:2B:B0",
    "BC:24:11:58:2E:60"
  ]
}

resource "proxmox_vm_qemu" "wicys-attack" {
  count       = 15
  name        = "user${count.index + 1}-attack"
  target_node = "chai"

  # VM Settings
  onboot   = true
  memory   = 2400
  vm_state = "started"

  # CPU settings
  cpu {
    type  = "x86-64-v2-AES"
    cores = 2
  }

  # BIOS/Boot settings
  bios = "seabios"
  boot = "order=scsi0;ide2;net0"

  # Network settings
  network {
    id       = 0
    model    = "virtio"
    bridge   = "speed0"
    firewall = true
    macaddr  = local.wicys_attack_macaddrs[count.index]
  }

  # Clone VM
  clone = "wicys-attack"

  # SCSI hardware
  scsihw = "virtio-scsi-single"

  # OS type
  os_type = "l26"

  lifecycle {
    ignore_changes = [
      vm_state,
    ]
  }

}
