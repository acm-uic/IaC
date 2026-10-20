# Existing guest inventoried from Maid Café on 2026-10-15.

# rgw-proxy-1
resource "proxmox_virtual_environment_container" "ct_167" {
  environment_variables = {}
  node_name             = "coffee"
  protection            = false
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
    datastore_id  = "ceph"
    mount_options = []
    quota         = false
    replicate     = false
    size          = 16
  }
  initialization {
    hostname = "rgw-proxy-1"
    ip_config {
      ipv4 {
        address = "172.25.8.238/24"
      }
      ipv6 {
        address = "auto"
      }
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  memory {
    dedicated = 1024
    swap      = 1024
  }
  network_interface {
    bridge       = "speed1"
    enabled      = true
    firewall     = true
    host_managed = false
    mac_address  = "BC:24:11:83:A0:33"
    mtu          = 0
    name         = "eth0"
    rate_limit   = 0
    vlan_id      = 0
  }
  network_interface {
    bridge       = "speed0"
    enabled      = true
    firewall     = true
    host_managed = false
    mac_address  = "BC:24:11:7F:31:06"
    mtu          = 0
    name         = "eth1"
    rate_limit   = 0
    vlan_id      = 0
  }
  operating_system {
    template_file_id = ""
    type             = "ubuntu"
  }
  vm_id = 167

  lifecycle {
    # Power state and operator notes are maintained in Proxmox.
    # An omitted LXC cpuunits reads as 0, which the API cannot set. Preserve the host default.
    ignore_changes = [started, description, cpu[0].units]
  }
}
