# Disabled Talos VM definition; Proxmox allocates a new VMID when enabled.
# Verify the retained MAC and target-node storage before enabling.
resource "proxmox_virtual_environment_vm" "k8s_05" {
  name          = "hachimi"
  node_name     = "boba"
  vm_id         = 172
  pool_id       = "Kubernetes"
  bios          = "ovmf"
  boot_order    = ["virtio0", "ide2", "net0"]
  scsi_hardware = "virtio-scsi-single"
  on_boot       = true
  started       = false
  template      = false
  protection    = true
  tags          = ["kubernetes"]

  agent {
    # Do not wait for a guest agent during ISO installation.
    enabled = false
  }

  cpu {
    type  = "x86-64-v2-AES"
    cores = 8
  }

  memory {
    dedicated = 16384
  }

  disk {
    # Allocate a new blank disk; do not attach or clone an existing guest's disk.
    datastore_id = "local-lvm"
    interface    = "virtio0"
    file_format  = "raw"
    size         = 100
    iothread     = true
  }

  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = false
  }

  tpm_state {
    datastore_id = "local-lvm"
    version      = "v2.0"
  }

  # This existing ISO is the installation source; Talos configuration is separate.
  cdrom {
    interface = "ide2"
    file_id   = "cephfs:iso/talos-factory-1.14.3.iso"
  }

  network_device {
    model       = "virtio"
    bridge      = "speed2"
    firewall    = true
    vlan_id     = 9
    mac_address = "BC:24:11:58:3F:9C"
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    # Create stopped; subsequent runtime power state is operated in Proxmox.
    ignore_changes = [started]
  }
}
