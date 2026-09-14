data "azuread_client_config" "current" {}

locals {
  owners = distinct(concat([data.azuread_client_config.current.object_id], var.additional_owner_ids))
}

resource "azuread_application" "portal" {
  display_name     = "acm-member-portal-${var.deployment_env}"
  sign_in_audience = "AzureADMyOrg"
  owners           = local.owners

  web {
    redirect_uris = var.redirect_uris
    logout_url    = length(var.logout_uris) > 0 ? var.logout_uris[0] : null
  }

  # Graph delegated scopes. openid / profile / email are requested at runtime by
  # better-auth; grant admin consent in Entra after the first apply.
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "37f7f235-527c-4136-accd-4f02faf2b745"
      type = "Scope" # openid
    }
    resource_access {
      id   = "64a6cdd6-4a97-4e60-a3e8-d57ef873a778"
      type = "Scope" # email
    }
  }

  optional_claims {
    id_token { name = "email" }
    id_token { name = "upn" }
    id_token {
      name                  = "groups"
      additional_properties = ["sam_account_name"]
    }
  }
}

resource "azuread_service_principal" "portal" {
  client_id    = azuread_application.portal.client_id
  use_existing = true
  owners       = local.owners
}

resource "azuread_application_password" "portal" {
  application_id = azuread_application.portal.id
  display_name   = "portal-${var.deployment_env}"
  rotate_when_changed = {
    rotation = time_rotating.rotation.id
  }
}

resource "time_rotating" "rotation" {
  rotation_days = 180
}

resource "random_password" "auth" {
  length  = 48
  special = false
}

resource "kubernetes_secret_v1" "portal" {
  metadata {
    name      = "portal-secrets"
    namespace = var.kubernetes_namespace
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = [data, binary_data]
  }
}

resource "kubernetes_secret_v1_data" "portal" {
  metadata {
    name      = kubernetes_secret_v1.portal.metadata[0].name
    namespace = kubernetes_secret_v1.portal.metadata[0].namespace
  }

  data = {
    BETTER_AUTH_SECRET      = random_password.auth.result
    MICROSOFT_CLIENT_ID     = azuread_application.portal.client_id
    MICROSOFT_CLIENT_SECRET = azuread_application_password.portal.value
    MICROSOFT_TENANT_ID     = data.azuread_client_config.current.tenant_id
  }

  field_manager = "terraform-acm-member-portal"
  force         = true
}
