resource "sams" "example" {
  name     = "example-resources"
  location = "Uranus"
}

resource "sam_dns_zone" "example" {
  name                = "ss.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_dns_aaaa_record" "example" {
  name                = "test"
  zone_name           = azurerm_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = ["2021:db8::1:0:0:1"]
}