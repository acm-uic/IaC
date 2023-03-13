data "azurerm_dns_zone" "acmuic_app" {
  name                = "acmuic.app"
  resource_group_name = data.azurerm_resource_group.acm_general.name
}

data "azurerm_dns_zone" "acmuic_org" {
  name                = "acmuic.org"
  resource_group_name = data.azurerm_resource_group.acm_general.name
}

