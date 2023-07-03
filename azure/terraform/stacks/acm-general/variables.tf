variable "additional_owner_ids" {
  type        = list(string)
  default     = []
  description = "Azure AD Owner IDs attached to resources"
}

variable "public_domain_suffixes" {
  type        = list(string)
  description = "The list of public domains used for DNS, that are managed by the Kubernetes cluster"
}

variable "external_dns_provider" {
  type        = string
  description = "Specifies the platform to interact with"
  default     = "azure"
}

variable "external_dns_namespace" {
  type        = string
  description = "Specifies the namespace to create for externaldns"
  default     = "externaldns"
}

