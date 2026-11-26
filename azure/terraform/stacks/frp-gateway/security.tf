locals {
  services = {
    web           = { priority = 100, ports = ["80", "443"], sources = ["0.0.0.0/0", "::/0"] }
    control       = { priority = 110, ports = ["7000"], sources = var.source_cidrs.control }
    vm-ssh        = { priority = 120, ports = ["22"], sources = var.source_cidrs.vm_ssh }
    forwarded-ssh = { priority = 130, ports = ["2222"], sources = var.source_cidrs.forwarded_ssh }
  }
  rules = flatten([for service, rule in local.services : [
    for index, family in ["v4", "v6"] : {
      name     = "${service}-${family}"
      priority = rule.priority + index
      ports    = rule.ports
      sources  = [for p in rule.sources : p if strcontains(p, ":") == (family == "v6")]
    }
  ]])
}

resource "azurerm_network_security_group" "gateway" {
  name                = "${var.name}-nsg"
  resource_group_name = azurerm_resource_group.gateway.name
  location            = azurerm_resource_group.gateway.location

  dynamic "security_rule" {
    for_each = { for r in local.rules : r.name => r if length(r.sources) > 0 }
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = security_rule.value.sources
      destination_port_ranges    = security_rule.value.ports
      destination_address_prefix = "*"
    }
  }

  # Precedes Azure's built-in AllowVnetInBound and AllowAzureLoadBalancerInBound.
  security_rule {
    name                       = "deny-other-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
