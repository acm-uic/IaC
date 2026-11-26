locals {
  ssh_forward = length(var.source_cidrs.forwarded_ssh) > 0
  server_files = {
    "/opt/frp/compose.yaml"            = file("${path.module}/server/compose.yaml")
    "/opt/frp/compose.ssh.yaml"        = file("${path.module}/server/compose.ssh.yaml")
    "/opt/frp/frps.toml"               = file("${path.module}/server/frps.toml")
    "/opt/frp/fetch-bundle.py"         = file("${path.module}/server/fetch-bundle.py")
    "/etc/systemd/system/frps.service" = file("${path.module}/server/frps.service")
    "/opt/frp/.env" = join("\n", [
      "COMPOSE_FILE=compose.yaml${local.ssh_forward ? ":compose.ssh.yaml" : ""}",
      "FRP_ENABLE_SSH=${local.ssh_forward}",
      "AZURE_CLIENT_ID=${azurerm_user_assigned_identity.server.client_id}",
      "FRP_BUNDLE_URL=${trimsuffix(data.azurerm_key_vault.existing.vault_uri, "/")}/secrets/${var.vault.secret_name}",
    ])
    "/etc/netplan/90-frp-ipv6.yaml" = yamlencode({
      network = { version = 2, ethernets = { eth0 = { dhcp4 = true, dhcp6 = true, accept-ra = true } } }
    })
  }
  cloud_config = {
    package_update = true
    packages       = ["docker.io", "docker-compose-v2", "ca-certificates"]
    write_files = [for path, content in local.server_files : {
      path = path, content = content, owner = "root:root", permissions = startswith(path, "/etc/netplan") ? "0600" : "0644"
    }]
    runcmd = [
      ["netplan", "apply"],
      ["systemctl", "enable", "--now", "docker.service"],
      ["systemctl", "daemon-reload"],
      ["systemctl", "enable", "--now", "frps.service"],
    ]
  }
}

resource "azurerm_linux_virtual_machine" "gateway" {
  name                            = var.name
  resource_group_name             = azurerm_resource_group.gateway.name
  location                        = azurerm_resource_group.gateway.location
  size                            = var.vm_size
  admin_username                  = "gatewayadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.gateway.id]
  custom_data                     = base64encode("#cloud-config\n${yamlencode(local.cloud_config)}")
  depends_on                      = [azurerm_network_interface_security_group_association.gateway, azurerm_role_assignment.bundle_reader]

  admin_ssh_key {
    username   = "gatewayadmin"
    public_key = trimspace(var.admin_ssh_public_key)
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.server.id]
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = var.image_version
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 32
  }
}
