variable "additional_owner_ids" {
  type        = list(string)
  default     = []
  description = "Azure AD Owner IDs attached to resources"
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub token used for updating secrets in website repo"
}
