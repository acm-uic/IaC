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
}

variable proxmox_url {
  type = string
  description = "URL to access the proxmox API. In the form of: https://proxmox-server01.example.com:8006/api2/json"
}
