resource "proxmox_vm_qemu" "k8s_01" {
  name        = "k8s-01"
  target_node = "boba"
  clone_id    = "101"

  # VM Settings
  cores   = 4
  sockets = 1
  memory  = 4096
  cpu     = "x86-64-v2-AES"
  numa    = false
  onboot  = true

  # BIOS/Boot settings
  bios = "ovmf"
  boot = "order=virtio0;ide2;net0"

  # EFI disk
  efidisk {
    storage = "ceph"
    efitype = "4m"
  }

  # TPM
  tpmstate0 {
    storage = "ceph"
  }

  # Network settings
  network {
    model    = "virtio"
    bridge   = "speed2"
    firewall = true
    macaddr  = "BC:24:11:84:15:8B"
  }

  # Main disk (virtio0)
  disk {
    type     = "virtio"
    storage  = "ceph"
    size     = "100G"
    iothread = 1
  }

  # SCSI hardware
  scsihw = "virtio-scsi-single"

  # OS type
  ostype = "l26"

  # CD-ROM (ide2)
  cdrom {
    iso = "cephfs:iso/taloslinux-cached-amd64-20250522.iso"
  }

  # Increase default timeout for VM creation
  timeouts {
    create = "10m"
    delete = "5m"
  }
}
