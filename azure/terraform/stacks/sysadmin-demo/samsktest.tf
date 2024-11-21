resource "azurerm_dns_aaaa_record" "samsktest" {
  name                = "samsk"
  zone_name           = data.azurerm_dns_zone.acmuic_org.name
  resource_group_name = data.azurerm_dns_zone.acmuic_org.resource_group_name
  ttl                 = 300
  records             = ["fdc5:2d46:cdc1:b358:5a47:caff:fe77:e556"] # User-local address of Coffee
}