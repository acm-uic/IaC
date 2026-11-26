variable "name" {
  description = "Gateway VM name and prefix for dedicated resources."
  type        = string
  default     = "umapyoi-frp"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.name))
    error_message = "Use a short alphanumeric DNS label, optionally with internal hyphens."
  }
}

variable "location" {
  type    = string
  default = "northcentralus"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "image_version" {
  description = "Reviewed Canonical Ubuntu 24.04 AMD64 Gen2 image version."
  type        = string
  default     = "24.04.202611170"
}

variable "admin_ssh_public_key" {
  type = string
  validation {
    condition     = can(regex("^ssh-(rsa|ed25519) [A-Za-z0-9+/=]+", trimspace(var.admin_ssh_public_key)))
    error_message = "Supply an OpenSSH public key."
  }
}

variable "ipv4_network" {
  type    = string
  default = "10.83.0.0/16"
  validation {
    condition     = try(can(cidrnetmask(var.ipv4_network)) && tonumber(split("/", var.ipv4_network)[1]) <= 24, false)
    error_message = "Supply an IPv4 network of /24 or larger. Its first /24 is used for the subnet."
  }
}

variable "ipv6_network" {
  type    = string
  default = "fd63:31e2:a40b::/48"
  validation {
    condition     = try(strcontains(var.ipv6_network, ":") && can(cidrhost(var.ipv6_network, 0)) && tonumber(split("/", var.ipv6_network)[1]) <= 64, false)
    error_message = "Supply an IPv6 network of /64 or larger. Its first /64 is used for the subnet."
  }
}

variable "source_cidrs" {
  description = "Restricted source networks for FRP control, VM SSH, and forwarded SSH. Empty SSH lists disable each feature."
  type = object({
    control       = set(string)
    vm_ssh        = optional(set(string), [])
    forwarded_ssh = optional(set(string), [])
  })
  validation {
    condition = length(var.source_cidrs.control) > 0 && alltrue([
      for prefix in concat(tolist(var.source_cidrs.control), tolist(var.source_cidrs.vm_ssh), tolist(var.source_cidrs.forwarded_ssh)) :
      can(cidrhost(prefix, 0)) && try(tonumber(split("/", prefix)[1]) > 0, false)
    ])
    error_message = "Provide the site's control egress CIDRs and only explicitly authorized SSH CIDRs. Catch-all prefixes are rejected."
  }
}

variable "vault" {
  description = "Existing RBAC-enabled Azure Key Vault and preseeded server bundle secret."
  type = object({
    name           = string
    resource_group = string
    secret_name    = string
  })
  default = {
    name           = "black-book"
    resource_group = "acm-general"
    secret_name    = "umapyoi-frps"
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.vault.secret_name))
    error_message = "Use a valid Key Vault secret name."
  }
}

variable "dns" {
  description = "Opt-in Terraform-owned gateway/application labels in one existing zone. Leave null until DNS cutover is authorized."
  type = object({
    zone           = string
    resource_group = string
    labels         = set(string)
    ttl            = optional(number, 300)
  })
  default = null
}

variable "budget" {
  description = "Optional resource-group monthly budget in billing currency. Use the first of the current month at creation."
  type = object({
    amount     = optional(number, 15)
    start_date = string
    emails     = list(string)
  })
  default = null
  validation {
    condition     = var.budget == null ? true : (length(var.budget.emails) > 0 && var.budget.amount > 0)
    error_message = "Configure a positive amount and at least one alert recipient."
  }
}
