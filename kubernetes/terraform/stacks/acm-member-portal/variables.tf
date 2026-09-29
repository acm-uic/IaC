variable "deployment_env" {
  type        = string
  description = "dev | prod. Used in the Entra app display name and client secret name."
  default     = "prod"
}

variable "redirect_uris" {
  type        = list(string)
  description = "OAuth2 redirect URIs registered on the Entra app."
}

variable "logout_uris" {
  type        = list(string)
  description = "Front-channel logout URIs."
  default     = []
}

variable "kubernetes_namespace" {
  type        = string
  description = "Namespace for the portal-secrets Secret. Must already exist (Argo CD creates acm-portal)."
  default     = "acm-portal"
}

variable "additional_owner_ids" {
  type        = list(string)
  default     = []
  description = "Extra Entra object IDs to set as app / service principal owners."
}
