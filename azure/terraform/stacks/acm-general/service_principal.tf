data "azuread_client_config" "current" {}

resource "azuread_application" "terraform_sysadmin_demo" {
  display_name = "terraform-sysadmindemo-svc"
  owners       = concat([data.azuread_client_config.current.object_id], var.additional_owner_ids)
}

resource "azuread_service_principal" "terraform_sysadmin_demo" {
  application_id               = azuread_application.terraform_sysadmin_demo.application_id
  app_role_assignment_required = false
  owners                       = concat([data.azuread_client_config.current.object_id], var.additional_owner_ids)
}

resource "azuread_application_password" "terraform_sysadmin_demo" {
  application_object_id = azuread_application.terraform_sysadmin_demo.object_id
  display_name          = "rbac-sysadmindemo-apppass"
  end_date_relative     = "240h"
}

