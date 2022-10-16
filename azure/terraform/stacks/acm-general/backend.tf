terraform {
  backend "azurerm" {
    resource_group_name  = "acm-hybridcloud"
      storage_account_name = "acmhybridstore"
      container_name       = "acm-terraform-state"
      key                  = "acm-general.tfstate"
  }
}
