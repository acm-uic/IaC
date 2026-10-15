# Existing guest inventoried from Maid Café on 2026-10-15.

# bp-webserver-01
resource "proxmox_virtual_environment_vm" "vm_141" {
  acpi            = true
  bios            = "seabios"
  boot_order      = ["scsi0", "ide2", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:BC:F6:57"]
  name            = "bp-webserver-01"
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:BC:F6:57"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "matcha"
  on_boot       = false
  pool_id       = "ButterPizza"
  protection    = true
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = []
  template      = false
  vm_id         = 141
  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }
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
    datastore_id      = "local-lvm"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "scsi0"
    iothread          = true
    path_in_datastore = "vm-141-disk-0"
    queues            = 0
    replicate         = true
    size              = 32
    ssd               = false
  }
  memory {
    dedicated      = 2048
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  smbios {
    uuid = "848fb16b-d617-45b5-9fb0-669e7010137a"
  }
  cdrom {
    interface = "ide2"
    file_id   = "local:iso/Leap-16.0-offline-installer-x86_64.install.iso"
  }

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios, cdrom]
  }
}
