variable target_node {
  type = string
  description = "The name of the node to provision this VM on"
}

variable iso_filename {
  type = string
  description = "The filename of the ISO image used to provision this VM"
}

variable ram_mb {
  type = number
  description = "The number of megabytes used for RAM"
  default = 2048
}

variable worker_prefix {
  type = string
  description = "The name of the VM in Proxmox"
  default = "github-worker"
}
