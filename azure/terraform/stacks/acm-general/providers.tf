terraform {
  required_version = "1.5.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.63.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

