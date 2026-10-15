# Existing guest inventoried from Maid Café on 2026-10-15.

# bootc-builder
resource "proxmox_virtual_environment_vm" "vm_110" {
  acpi            = true
  bios            = "ovmf"
  boot_order      = ["scsi0", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:AC:BD:E5", "BC:24:11:16:E6:2C"]
  machine         = "q35"
  name            = "bootc-builder"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:AC:BD:E5"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  network_device {
    bridge       = "speed1"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:16:E6:2C"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "boba"
  on_boot       = true
  pool_id       = "Bootc"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = ["bootc"]
  template      = false
  vm_id         = 110
  cpu {
    cores      = 8
    flags      = []
    hotplugged = 0
    limit      = 0
    numa       = false
    sockets    = 1
    type       = "host"
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
    path_in_datastore = "vm-110-disk-1"
    queues            = 0
    replicate         = true
    size              = 100
    ssd               = false
  }
  efi_disk {
    datastore_id      = "ceph"
    file_format       = "raw"
    pre_enrolled_keys = true
    type              = "4m"
  }
  memory {
    dedicated      = 8192
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  smbios {
    uuid = "dddf8b29-0b67-4fa9-9349-ed7ca9f9d381"
  }

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios]
  }
}

# Preserve the existing HA policy for the running bootc builder.
resource "proxmox_haresource" "bootc_builder" {
  resource_id  = "vm:110"
  state        = "started"
  max_restart  = 10
  max_relocate = 0

  lifecycle {
    prevent_destroy = true
  }
}
