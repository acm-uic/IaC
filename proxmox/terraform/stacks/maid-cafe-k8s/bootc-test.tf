# Existing guest inventoried from Maid Café on 2026-10-15.

# bootc-test
resource "proxmox_virtual_environment_vm" "vm_111" {
  acpi            = true
  bios            = "ovmf"
  boot_order      = ["scsi0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:6E:DA:DD"]
  machine         = "q35"
  name            = "bootc-test"
  network_device {
    bridge       = "speed0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:6E:DA:DD"
    model        = "virtio"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "matcha"
  on_boot       = false
  pool_id       = "Bootc"
  protection    = false
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = ["bootc"]
  template      = false
  vm_id         = 111
  cpu {
    cores      = 4
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
    path_in_datastore = "vm-111-disk-1"
    queues            = 0
    replicate         = true
    size              = 32
    ssd               = false
  }
  efi_disk {
    datastore_id      = "ceph"
    file_format       = "raw"
    pre_enrolled_keys = true
    type              = "4m"
  }
  memory {
    dedicated      = 4096
    floating       = 0
    keep_hugepages = false
    shared         = 0
  }
  operating_system {
    type = "l26"
  }
  smbios {
    uuid = "0fed2fa6-cb8c-4b1e-bb3a-a2459cffb6e6"
  }

  lifecycle {
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios]
  }
}
