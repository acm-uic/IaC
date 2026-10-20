# Existing guest inventoried from Maid Café on 2026-10-15.

# fp-db-01
resource "proxmox_virtual_environment_vm" "vm_134" {
  # Additional CD-ROM ide0 remains operated in Proxmox: local:iso/virtio-win-0.1.302.iso
  acpi            = true
  bios            = "ovmf"
  boot_order      = ["scsi0", "ide2", "net0", "ide0"]
  keyboard_layout = "en-us"
  mac_addresses   = ["BC:24:11:0A:B5:E9"]
  machine         = "pc-q35-9.2+pve1"
  name            = "fp-db-01"
  network_device {
    bridge       = "vmbr0"
    disconnected = false
    firewall     = true
    mac_address  = "BC:24:11:0A:B5:E9"
    model        = "e1000"
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
  }
  node_name     = "matcha"
  on_boot       = false
  pool_id       = "FlamePenguins"
  protection    = true
  scsi_hardware = "virtio-scsi-single"
  started       = false
  tablet_device = true
  tags          = []
  template      = false
  vm_id         = 134
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
    path_in_datastore = "vm-134-disk-1"
    queues            = 0
    replicate         = true
    size              = 40
    ssd               = false
  }
  efi_disk {
    datastore_id      = "local-lvm"
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
    type = "win11"
  }
  smbios {
    uuid = "f6f17454-347f-4740-8c27-602a760378d6"
  }
  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }
  cdrom {
    interface = "ide2"
    file_id   = "local:iso/en-us_windows_server_2022_updated_july_2023_x64_dvd_541692c3.iso"
  }

  lifecycle {
    # Power state and operator notes are maintained in Proxmox.
    # Preserve existing peripheral state that the provider does not hydrate during import.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, smbios, cdrom, tpm_state]
  }
}
