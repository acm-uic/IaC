terraform {
  required_version = ">= 1.9.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.116.1"
    }
    # Retained only so the old state entry can be detached without destroying it.
    legacyproxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc02"
    }
  }
}

provider "proxmox" {
  endpoint  = trimsuffix(trimsuffix(var.proxmox_api_url, "/"), "/api2/json")
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}

provider "legacyproxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}
