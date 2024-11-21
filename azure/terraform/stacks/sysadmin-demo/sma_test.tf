resource "azurerm_dns_a_record" "sams machine" {
  name                = "lemonade"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 65
  records             = ["fdc5:2d46:cdc1:b358:5a47:caff:fe77:e557"]
}