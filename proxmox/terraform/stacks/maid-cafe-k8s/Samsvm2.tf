# Existing guest inventoried from Maid Café on 2026-10-15.

# Samsvm2
resource "proxmox_virtual_environment_vm" "vm_128" {
  acpi            = true
  bios            = "ovmf"
  boot_order      = ["scsi0", "ide2", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:1E:D7:6B"]
  name            = "Samsvm2"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:1E:D7:6B"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "chai"
  on_boot       = false
  protection    = true
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = []
  template      = false
  vm_id         = 128
  cpu {
    cores      = 8
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 2
    type       = "x86-64-v2-AES"
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-128-disk-1"
    queues            = 0
    replicate         = true
    size              = 512
    ssd               = false
  }
  efi_disk {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    pre_enrolled_keys = true
    type              = "4m"
  }
  memory {
    dedicated      = 15259
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  vga {
    type = "virtio"
  }
  smbios {
    uuid = "76b8b648-239c-45d3-8867-8a5acfcce7c3"
  }
  cdrom {
    interface = "ide2"
    file_id   = "cephfs:iso/archlinux-2025.05.01-x86_64.iso"
  }

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios, cdrom]
  }
}
