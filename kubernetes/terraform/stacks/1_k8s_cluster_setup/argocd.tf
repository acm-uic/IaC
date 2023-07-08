resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
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

}


