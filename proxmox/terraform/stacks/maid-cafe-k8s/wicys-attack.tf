# Existing guest inventoried from Maid Café on 2026-10-15.

# wicys-attack (template)
resource "proxmox_virtual_environment_vm" "vm_115" {
  acpi            = true
  bios            = "seabios"
  boot_order      = ["scsi0", "ide2", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:F3:EA:FE"]
  name            = "wicys-attack"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:F3:EA:FE"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "chai"
  on_boot       = false
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = []
  template      = true
  vm_id         = 115
  cpu {
    cores      = 2
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 1
    type       = "x86-64-v2-AES"
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "ceph"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "base-115-disk-0"
    queues            = 0
    replicate         = true
    size              = 32
    ssd               = false
  }
  memory {
    dedicated      = 2400
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  smbios {
    uuid = "46889e8c-68a4-42ce-8222-ed2d81af31fe"
  }
  cdrom {
    interface = "ide2"
    file_id   = "cephfs:iso/kali-linux-2025.2-installer-amd64.iso"
  }

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios, cdrom]
  }
}
