resource "proxmox_vm_qemu" "k8s_03" {
  name        = "k8s-03"
  target_node = "coffee"

  # VM Settings
  onboot   = true
  memory   = 4096
  vm_state = "stopped"
  pool     = "Kubernetes"

  # CPU settings
  cpu {
    type  = "x86-64-v2-AES"
    cores = 4
  }

  # BIOS/Boot settings
  bios = "ovmf"
  boot = "order=virtio0;ide2;net0"

  # EFI disk
  efidisk {
    storage = "ceph"
    efitype = "4m"
  }

  # TPM
  tpm_state {
    storage = "ceph"
  }

  # Network settings
  network {
    id       = 0
    model    = "virtio"
    bridge   = "speed2"
    firewall = true
    macaddr  = "BC:24:11:E4:10:66"
  }

  # Main disk (virtio0)
  disk {
    slot     = "virtio0"
    type     = "disk"
    storage  = "ceph"
    size     = "100G"
    iothread = true
  }

  # SCSI hardware
  scsihw = "virtio-scsi-single"

  # OS type
  os_type = "l26"

  # CD-ROM (ide2)
  disk {
    slot = "ide2"
    type = "cdrom"
    iso  = "cephfs:iso/taloslinux-cached-amd64-20250522.iso"
  }

}
