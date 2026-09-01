terraform {
  required_version = "1.9.8"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.1"
    }
  }
}

provider "azuread" {}

# Auth via KUBE_CONFIG_PATH / KUBECONFIG (set on the maid-cafe runner).
provider "kubernetes" {}
