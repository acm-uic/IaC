terraform {
  required_version = ">= 1.9.8, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "acm-hybridcloud"
    storage_account_name = "acmhybridstore"
    container_name       = "acm-terraform-state"
    key                  = "umapyoi-frp-gateway.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
