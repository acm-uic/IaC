data "azurerm_dns_zone" "acmuic_app" {
  name                = "acmuic.app"
  resource_group_name = azurerm_resource_group.acm_general.name
}

data "azurerm_dns_zone" "acmuic_org" {
  name                = "acmuic.org"
  resource_group_name = azurerm_resource_group.acm_general.name
}

resource "azurerm_dns_cname_record" "flourishconf_acmuic_org" {
  name                = "flourishconf"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = azurerm_resource_group.acm_general.name
  ttl                 = 300
  record              = "docker1.acmuic.org"
}

output "azurerm_dns_zone_acm_uic" {
  value = data.azurerm_dns_zone.acmuic_org
}
