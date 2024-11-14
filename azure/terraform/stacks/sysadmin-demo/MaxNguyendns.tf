resource "azurerm_dns_aaaa_record" "Overlord_MaxNguyen" {
  name                = "overlord-max"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 300
  records             = ["fdc5:2d46:cdc1:b358::1"]
}
