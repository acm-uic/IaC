resource "kubernetes_namespace" "external_dns_namespace" {
  metadata {
    name = var.external_dns_namespace
  }
}

locals {
  volume_mounts = {
      "name": "azure-config-file", 
      "mountPath": "/etc/kubernetes", 
      "readOnly": true
    }
}

#data "helm_template" "external_dns" {
resource "helm_release" "external_dns" {
  name       = "external-dns-release"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version
  namespace  = var.external_dns_namespace

  set {
    name  = "domainFilters"
    value = format("{%s}", join(",", var.public_domain_suffixes))
  }

  set {
    name = "provider"
    value = var.external_dns_provider
  }

  set {
    name = "txtPrefix"
    value = "${var.external_dns_namespace}_"
  }


#  set {
#    name = "extraArgs"
#    value = "{--dry-run}"
#  }

  set {
    name = "extraVolumeMounts[0].name"
    value = local.volume_mounts.name
  }
  set {
    name = "extraVolumeMounts[0].mountPath"
    value = local.volume_mounts.mountPath
  }
  set {
    name = "extraVolumeMounts[0].readOnly"
    value = local.volume_mounts.readOnly
  }

  set {
    name = "extraVolumes[0].name"
    value = "azure-config-file"
  }
  set {
    name = "extraVolumes[0].secret.secretName"
    value = "azure-config-file"
  }
  set {
    name = "extraVolumes[0].secret.items[0].key"
    value = "azure.json"
  }
  set {
    name = "extraVolumes[0].secret.items[0].path"
    value = "azure.json"
  }
}

#output "test" {
#  value = data.helm_template.external_dns.manifests
#}

resource "kubernetes_secret" "azure_config_file" {
  metadata {
    name = "azure-config-file"
    namespace = var.external_dns_namespace
  }

  data = {
    "azure.json" = jsonencode({
      "tenantId": var.azure_tenant_id,
      "subscriptionId": var.azure_subscription_id,
      "resourceGroup": var.azure_dns_resource_group,
      "aadClientId": azuread_application.externaldns.application_id,
      "aadClientSecret": azuread_service_principal_password.externaldns.value
    })
  }
}
