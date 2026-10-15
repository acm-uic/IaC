# Existing guest inventoried from Maid Café on 2026-10-15.

# pi-nas
resource "proxmox_virtual_environment_vm" "vm_112" {
  acpi            = true
  bios            = "ovmf"
  boot_order      = ["virtio0", "ide2", "net0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:42:87:AD", "BC:24:11:28:5C:5C"]
  name            = "pi-nas"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:42:87:AD"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  network_device {
    bridge       = "speed2"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:28:5C:5C"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 7
  }
  node_name     = "matcha"
  on_boot       = true
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = true
  tablet_device = true
  tags          = []
  template      = false
  vm_id         = 112
  cpu {
    cores      = 4
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
    interface         = "virtio0"
    iothread          = true
    path_in_datastore = "vm-112-disk-2"
    queues            = 0
    replicate         = true
    size              = 32
    ssd               = false
  }
  disk {
    aio               = "io_uring"
    backup            = true
    cache             = "none"
    datastore_id      = "ceph"
    discard           = "ignore"
    file_format       = "raw"
    interface         = "virtio1"
    iothread          = true
    path_in_datastore = "vm-112-disk-3"
    queues            = 0
    replicate         = true
    size              = 100
    ssd               = false
  }
  efi_disk {
    datastore_id      = "ceph"
    file_format       = "raw"
    pre_enrolled_keys = false
    type              = "4m"
  }
  memory {
    dedicated      = 8196
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  tpm_state {
    datastore_id = "ceph"
    version      = "v2.0"
  }
  smbios {
    uuid = "63aa7cae-e8db-4db4-99fe-9fd8d80bc846"
  }
  cdrom {
    interface = "ide2"
    file_id   = "none"
  }

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios, cdrom]
  }
}
