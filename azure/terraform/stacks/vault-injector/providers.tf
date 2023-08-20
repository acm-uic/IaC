terraform {
  required_version = "1.5.2"
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.19.0"
    }
  }
}

provider "vault" {
  # Configuration options
}
