# Existing guest inventoried from Maid Café on 2026-10-15.

# ani-frontend
resource "proxmox_virtual_environment_container" "ct_117" {
  environment_variables = {}
  node_name             = "chai"
  protection            = true
  start_on_boot         = false
  started               = false
  tags                  = []
  template              = false
  unprivileged          = true
  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }
  cpu {
    architecture = "amd64"
    cores        = 2
    limit        = 0
  }
  disk {
    acl           = false
    datastore_id  = "local-lvm"
    mount_options = []
    quota         = false
    replicate     = false
    size          = 32
  }
  features {
    fuse    = false
    keyctl  = false
    mknod   = false
    mount   = []
    nesting = true
  }
  initialization {
    hostname = "ani-frontend"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
  memory {
    dedicated = 4096
    swap      = 2048
  }
  network_interface {
    bridge       = "speed0"
    enabled      = true
    firewall     = true
    host_managed = false
    mac_address  = "BC:24:11:4C:BA:03"
    mtu          = 0
    name         = "eth0"
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    template_file_id = ""
    type             = "fedora"
  }
  vm_id = 117

  lifecycle {
    # Power state and operator notes are maintained in Proxmox.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, cpu[0].units]
  }
}
