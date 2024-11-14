resource "azurerm_dns_a_record" "chasetest" {
  name                = "chasetest"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 60
  records             = ["127.0.0.1"]
}
