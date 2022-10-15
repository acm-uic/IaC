variable "public_domain_suffixes" {
  type = list(string)
  description = "The list of public domains used for DNS, that are managed by the Kubernetes cluster"
}

variable "external_dns_chart_version" {
  type = string
  description = "Specifies the external-dns helm chart version"
}

variable "external_dns_provider" {
  type = string
  description = "Specifies the platform to interact with"
  default = "azure"
}

variable "external_dns_namespace" {
  type = string
  description = "Specifies the namespace to create for externaldns"
  default = "externaldns"
}

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

