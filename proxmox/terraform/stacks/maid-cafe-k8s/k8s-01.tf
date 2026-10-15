# A new Talos VM, separate from the legacy address that points to VM 107.
# VMID 168 and this MAC were verified unused on 2026-10-15.
resource "proxmox_virtual_environment_vm" "k8s_01" {
  name          = "k8s-01"
  node_name     = "boba"
  vm_id         = 168
  pool_id       = "Kubernetes"
  bios          = "ovmf"
  boot_order    = ["virtio0", "ide2", "net0"]
  scsi_hardware = "virtio-scsi-single"
  on_boot       = true
  started       = false
  template      = false
  protection    = true

  agent {
    # Do not wait for a guest agent during ISO installation.
    enabled = false
  }

  cpu {
    type  = "x86-64-v2-AES"
    cores = 4
  }

  memory {
    dedicated = 4096
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
    mac_address = "BC:24:11:84:15:8B"
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    prevent_destroy = true
    # Create stopped; subsequent runtime power state is operated in Proxmox.
    ignore_changes = [started]
  }
}
