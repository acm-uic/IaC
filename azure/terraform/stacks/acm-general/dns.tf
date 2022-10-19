data "azurerm_dns_zone" "acmuic_app" {
  name                = "acmuic.app"
  resource_group_name = azurerm_resource_group.acm_general.name
}

resource "azurerm_dns_cname_record" "chase_demo" {
  name                = "chasedemo"
  zone_name           = data.azurerm_dns_zone.acmuic_app.name
  resource_group_name = azurerm_resource_group.acm_general.name
  ttl                 = 300
  record              = "sysadmin.acmapp.tech"
}
