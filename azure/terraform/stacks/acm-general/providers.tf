terraform {
  required_version = "1.3.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

