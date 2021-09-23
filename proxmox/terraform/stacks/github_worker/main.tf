resource "proxmox_vm_qemu" "github_worker" {
  name = "github-worker"
  desc = "VM for GitHub Action workloads"
  target_node = var.target_node
  bios = "ovmf"
  iso = var.iso_filename
  memory = var.ram_mb
  cores = 2
  os_type = "cloud-init"

  network {
    model = "virtio"
    tag = 1
  }

  disk {
    type = "sata"
    storage = "acm-nfs"
    size = "30G"
  }
}
