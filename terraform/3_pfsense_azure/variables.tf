variable "azure_tenant_id" {
  type = string
  description = "The tenantId of the Azure account"
}

variable "azure_subscription_id" {
  type = string
  description = "The subscriptionId of the Azure account"
}

variable "azure_dns_resource_group" {
  type = string
  description = "The resourceGroup of the DNS Zone"
}

variable "pfsense_namespace" {
  type = string
  default = "pfsense"
  description = "The name to prefix resources with"
}

variable "public_domain_suffixes" {
  type = list(string)
  description = "The list of public domains used for DNS, that are managed by the Kubernetes cluster"
}

