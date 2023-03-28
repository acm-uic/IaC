terraform {
  required_version = "1.4.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.49.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.36.0"
    }

    github = {
      source  = "integrations/github"
      version = "5.18.3"
    }
  }
}

provider "github" {
  owner = "acm-uic"
}

provider "azuread" {
  # Configuration options
}

provider "azurerm" {
  # Configuration options
  features {}
}
