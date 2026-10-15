# Existing guest inventoried from Maid Café on 2026-10-15.

# ansible-test1
resource "proxmox_virtual_environment_container" "ct_120" {
  environment_variables = {}
  node_name             = "coffee"
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
  disk {
    acl           = false
    datastore_id  = "local-lvm"
    mount_options = []
    quota         = false
    replicate     = false
    size          = 8
  }
  features {
    fuse    = false
    keyctl  = false
    mknod   = false
    mount   = []
    nesting = true
  }
  initialization {
    hostname = "ansible-test1"
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
    mac_address  = "BC:24:11:32:63:7F"
    mtu          = 0
    name         = "eth0"
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    template_file_id = ""
    type             = "ubuntu"
  }
  vm_id = 120

  lifecycle {
    prevent_destroy = true
    # Power state and operator notes are maintained in Proxmox.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, cpu[0].units]
  }
}
