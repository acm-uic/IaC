locals {
  default_tags = {
    owner   = "clee231@acmuic.org"
    project = "umapyoi-gateway"
  }
}

resource "azurerm_resource_group" "gateway" {
  name     = "${var.name}-rg"
  location = var.location
  tags     = local.default_tags
}

data "azurerm_key_vault" "existing" {
  name                = var.vault.name
  resource_group_name = var.vault.resource_group
}

resource "azurerm_user_assigned_identity" "server" {
  name                = "${var.name}-server"
  location            = azurerm_resource_group.gateway.location
  resource_group_name = azurerm_resource_group.gateway.name
  tags                = local.default_tags
}

resource "azurerm_role_assignment" "bundle_reader" {
  scope                = "${data.azurerm_key_vault.existing.id}/secrets/${var.vault.secret_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.server.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_dns_a_record" "gateway" {
  for_each            = var.dns == null ? toset([]) : var.dns.labels
  name                = each.key
  zone_name           = var.dns.zone
  resource_group_name = var.dns.resource_group
  ttl                 = var.dns.ttl
  records             = [azurerm_public_ip.gateway["IPv4"].ip_address]
  tags                = local.default_tags
}

resource "azurerm_dns_aaaa_record" "gateway" {
  for_each            = azurerm_dns_a_record.gateway
  name                = each.key
  zone_name           = var.dns.zone
  resource_group_name = var.dns.resource_group
  ttl                 = var.dns.ttl
  records             = [azurerm_public_ip.gateway["IPv6"].ip_address]
  tags                = local.default_tags
}

resource "azurerm_consumption_budget_resource_group" "gateway" {
  count             = var.budget == null ? 0 : 1
  name              = var.name
  resource_group_id = azurerm_resource_group.gateway.id
  amount            = var.budget.amount
  time_grain        = "Monthly"
  time_period {
    start_date = var.budget.start_date
  }
  notification {
    enabled        = true
    operator       = "GreaterThanOrEqualTo"
    threshold      = 90
    contact_emails = var.budget.emails
  }
}
