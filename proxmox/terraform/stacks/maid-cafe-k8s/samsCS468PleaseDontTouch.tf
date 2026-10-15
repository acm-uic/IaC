# Existing guest inventoried from Maid Café on 2026-10-15.

# samsCS468PleaseDontTouch
resource "proxmox_virtual_environment_vm" "vm_102" {
  acpi            = true
  bios            = "seabios"
  boot_order      = ["scsi0", "ide2", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:45:B0:9D"]
  name            = "samsCS468PleaseDontTouch"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:45:B0:9D"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "coffee"
  on_boot       = false
  protection    = true
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = []
  template      = false
  vm_id         = 102
  cpu {
    cores      = 3
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 4
    type       = "x86-64-v2-AES"
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "directsync"
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-102-disk-0"
    queues            = 0
    replicate         = true
    size              = 100
    ssd               = false
  }
  memory {
    dedicated      = 16000
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  smbios {
    uuid = "10040648-c561-4aeb-9dc4-4e6bc504e6f7"
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
