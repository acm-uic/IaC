resource "azurerm_virtual_network" "gateway" {
  name                = "${var.name}-vnet"
  resource_group_name = azurerm_resource_group.gateway.name
  location            = azurerm_resource_group.gateway.location
  address_space       = [var.ipv4_network, var.ipv6_network]
  tags                = local.default_tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  resource_group_name  = azurerm_resource_group.gateway.name
  virtual_network_name = azurerm_virtual_network.gateway.name
  address_prefixes = [
    cidrsubnet(var.ipv4_network, 24 - tonumber(split("/", var.ipv4_network)[1]), 0),
    cidrsubnet(var.ipv6_network, 64 - tonumber(split("/", var.ipv6_network)[1]), 0),
  ]
  default_outbound_access_enabled = false
}

resource "azurerm_public_ip" "gateway" {
  for_each            = toset(["IPv4", "IPv6"])
  name                = "${var.name}-${lower(each.key)}"
  resource_group_name = azurerm_resource_group.gateway.name
  location            = azurerm_resource_group.gateway.location
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = each.key
  tags                = local.default_tags
}

resource "azurerm_network_interface" "gateway" {
  name                = "${var.name}-nic"
  resource_group_name = azurerm_resource_group.gateway.name
  location            = azurerm_resource_group.gateway.location
  tags                = local.default_tags

  dynamic "ip_configuration" {
    for_each = ["IPv4", "IPv6"]
    content {
      name                          = lower(ip_configuration.value)
      subnet_id                     = azurerm_subnet.gateway.id
      primary                       = ip_configuration.value == "IPv4"
      private_ip_address_version    = ip_configuration.value
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.gateway[ip_configuration.value].id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "gateway" {
  network_interface_id      = azurerm_network_interface.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}
