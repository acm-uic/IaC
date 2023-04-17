terraform {
  required_version = "1.4.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.49.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.36.0"
    }
  }
}

provider "azuread" {
  # Configuration options
}

provider "azurerm" {
  # Configuration options
  features {}
}
