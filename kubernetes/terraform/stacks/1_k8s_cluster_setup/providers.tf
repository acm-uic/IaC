terraform {
  backend "kubernetes" {
    secret_suffix    = "acmstate"
}
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.39.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.63.0"
    }
  }
}

provider "helm" {
  # Configuration options
}

provider "azurerm" {
  features {}
}
