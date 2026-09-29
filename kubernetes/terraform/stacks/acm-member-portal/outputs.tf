output "application_id" {
  value = azuread_application.portal.id
}

output "client_id" {
  value = azuread_application.portal.client_id
}

output "service_principal_object_id" {
  value = azuread_service_principal.portal.object_id
}

output "secret_name" {
  value = kubernetes_secret_v1.portal.metadata[0].name
}
