resource "kubernetes_config_map" "cmp_plugin" {
  metadata {
    name      = "cmp-plugin"
    namespace = var.argocd_namespace
  }

  data = {
    "avp.yaml"      = file("avp.yaml")
    "avp-helm.yaml" = file("avp-helm.yaml")
  }
}

