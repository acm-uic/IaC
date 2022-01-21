terraform {
  backend "kubernetes" {
    secret_suffix    = "acmappstate"
}
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }
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

provider "helm" {
  # Configuration options
}

provider "azurerm" {
  features {}
}
