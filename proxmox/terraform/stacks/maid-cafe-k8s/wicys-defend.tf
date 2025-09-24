locals {
  wicys_defend_macaddrs = [
    "BC:24:11:DC:0B:85",
    "BC:24:11:5B:06:ED",
    "BC:24:11:77:91:60",
    "BC:24:11:20:2C:22",
    "BC:24:11:E1:A2:B5",
    "BC:24:11:B7:EC:67",
    "BC:24:11:E9:0A:1B",
    "BC:24:11:1E:EC:3E",
    "BC:24:11:96:A7:14",
    "BC:24:11:22:50:7B",
    "BC:24:11:DF:D8:5F",
    "BC:24:11:8B:A1:53",
    "BC:24:11:5F:C8:00",
    "BC:24:11:D1:4C:06",
    "BC:24:11:89:EB:5A"
  ]
}

resource "proxmox_vm_qemu" "wicys-defend" {
  count       = 15
  name        = "user${count.index + 1}-defend"
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
    macaddr  = local.wicys_defend_macaddrs[count.index]
  }

  # Clone VM
  clone = "wicys-defend"

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
