resource "azurerm_dns_aaaa_record" "notExamnple" {
  name                = "DrPepper"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 300
  records             = ["fdc5:2d46:cdc1:b358:5a47:caff:fe77:e556"]
}