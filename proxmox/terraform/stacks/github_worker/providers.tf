terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  # Configuration options
  pm_api_url = var.proxmox_url
  pm_tls_insecure = true
}
