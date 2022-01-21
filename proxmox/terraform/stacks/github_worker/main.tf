resource "random_pet" "name_randomizer" {
  prefix = var.worker_prefix
}

resource "proxmox_vm_qemu" "github_worker" {
  name = random_pet.name_randomizer.id
  desc = "VM for GitHub Action workloads"
  target_node = var.target_node
  bios = "seabios"
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
    format = "qcow2"
  }
}
