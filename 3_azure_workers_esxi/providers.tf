terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "1.25.0"
    }
  }
}

provider "vsphere" {
  # Configuration options
  # These are configured by environment variables
  # You must specify the following variables:
  # VSPHERE_USER - Service User Name
  # VSPHERE_PASSWORD - Service Password
  # VSPHERE_SERVER - vsphere server name
  # VSPHERE_ALLOW_UNVERIFIED_SSL - If the certificate sent by vsphere is not trusted on your client, set this to true. 
}
