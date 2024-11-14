resource "azurerm_dns_aaaa_record" "example" {
  name                = "test"
  zone_name           = "acmuic.org"
  resource_group_name = data.azurerm_resource_group.acm_general.name
  ttl                 = 300
  records             = ["2001:db8::1:0:0:1"]
}
