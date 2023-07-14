resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = var.argocd_namespace
  }
}

locals {
  argo_volume_cm          = [{
    name = "cmp-plugin"
    configMap = {
      name = "cmp-plugin"
    }},
    {
      name = "custom-tools"
        emptyDir = {}
    }
  ]
  argo_init_containers    = [{
          name    = "download-tools"
          image   = "registry.access.redhat.com/ubi8"
          command = ["sh", "-c"]
          args    = ["curl -L https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v$(AVP_VERSION)/argocd-vault-plugin_$(AVP_VERSION)_linux_amd64 -o argocd-vault-plugin && chmod +x argocd-vault-plugin && mv argocd-vault-plugin /custom-tools/"]

          env = [{
            name  = "AVP_VERSION"
            value = "1.11.0"
          }]

          volumeMounts = [{
            name       = "custom-tools"
            mountPath = "/custom-tools"
          }]
        }]
  argo_sidecar_containers = [
    {
      name    = "avp"
      image   = "registry.access.redhat.com/ubi8"
      command = ["/var/run/argocd/argocd-cmp-server"]

      volumeMounts = [{
        name       = "var-files"
        mountPath = "/var/run/argocd"
      },
      {
        name       = "plugins"
        mountPath = "/home/argocd/cmp-server/plugins"
      },
      {
        name       = "tmp"
        mountPath = "/tmp"
      },
      {
        name       = "cmp-plugin"
        mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
        subPath   = "avp.yaml"
      },
      {
        name       = "custom-tools"
        mountPath = "/usr/local/bin/argocd-vault-plugin"
        subPath   = "argocd-vault-plugin"
      }]

      securityContext = {
        runAsUser     = 999
        runAsNonRoot  = true
      }
    }
  ]
}

resource "helm_release" "argocd" {
  depends_on = [kubernetes_config_map.cmp_plugin]
  name       = "argocd-release"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = var.argocd_namespace

  set {
    name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = "cd.acmuic.org"
  }

  set {
    name  = "redis-ha.enabled"
    value = "true"
  }

  set {
    name  = "server.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "repoServer.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "repoServer.volumes"
    value = yamlencode(local.argo_volume_cm)
  }

  set {
    name  = "repoServer.initContainers"
    value = yamlencode(local.argo_init_containers)
  }

  set {
    name  = "repoServer.extraContainers"
    value = yamlencode(local.argo_sidecar_containers)
  }

}

