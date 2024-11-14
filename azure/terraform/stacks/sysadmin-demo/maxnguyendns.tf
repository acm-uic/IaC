resource "azurerm_dns_aaaa_record" "overlord-max-nguyen" {
  name                = "overlord-max-nguyen"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 30
  records             = ["fdc5:2d46:cdc1:b358::1"]
}
