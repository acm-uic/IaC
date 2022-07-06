terraform {
  backend "azurerm" {
    resource_group_name = "acm-hybridcloud"
    storage_account_name = "acmhybridstore"
    container_name = "acm-terraform-state"
    key = "pfsense_azure.terraform.tfstate"
  }
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "2.15.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.93.0"
    }
  }
}

provider "azurerm" {
  features {}
}
