resource "kubernetes_namespace" "external_dns_namespace" {
  metadata {
    name = var.external_dns_namespace
  }
}

locals {
  volume_mounts = {
    "name" : "azure-config-file",
    "mountPath" : "/etc/kubernetes",
    "readOnly" : true
  }
}

resource "kubernetes_secret" "azure_config_file" {
  metadata {
    name      = "azure-config-file"
    namespace = var.external_dns_namespace
  }

  data = {
    "azure.json" = jsonencode({
      "tenantId" : var.azure_tenant_id,
      "subscriptionId" : var.azure_subscription_id,
      "resourceGroup" : var.azure_dns_resource_group,
      "aadClientId" : azuread_application.externaldns.application_id,
      "aadClientSecret" : azuread_service_principal_password.externaldns.value
    })
  }
}
