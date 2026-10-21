# Existing guest inventoried from Maid Café on 2026-10-15.

# cafe-manager
resource "proxmox_virtual_environment_container" "ct_100" {
  environment_variables = {}
  node_name             = "boba"
  protection            = false
  start_on_boot         = true
  started               = true
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
    datastore_id  = "ceph"
    mount_options = []
    quota         = false
    replicate     = false
    size          = 10
  }
  features {
    fuse    = false
    keyctl  = false
    mknod   = false
    mount   = []
    nesting = true
  }
  initialization {
    hostname = "cafe-manager"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "auto"
      }
    }
  }
  memory {
    dedicated = 2048
    swap      = 512
  }
  network_interface {
    bridge       = "speed0"
    enabled      = true
    firewall     = true
    host_managed = false
    mac_address  = "BC:24:11:48:C9:66"
    mtu          = 0
    name         = "eth0"
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    template_file_id = ""
    type             = "archlinux"
  }
  vm_id = 100

  lifecycle {
    # Power state and operator notes are maintained in Proxmox.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, cpu[0].units]
  }
}
