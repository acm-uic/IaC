resource "azurerm_container_registry" "acmuic" {
  admin_enabled       = true
  location            = "northcentralus"
  name                = "acmuic"
  resource_group_name = "acm-general"
  sku                 = "Standard"
}
