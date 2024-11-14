resource "azurerm_dns_aaaa_record" "notExamnple" {
  name                = "DrPepper"
  zone_name           = azurerm_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = ["fdc5:2d46:cdc1:b358:5a47:caff:fe77:e556"]
}