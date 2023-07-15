resource "kubernetes_config_map" "cmp_plugin" {
  metadata {
    name      = "cmp-plugin"
    namespace = var.argocd_namespace
  }

  data = {
    "avp.yaml" = <<EOC
apiVersion: argoproj.io/v1alpha1
kind: ConfigManagementPlugin
metadata:
  name: argocd-vault-plugin
spec:
  allowConcurrency: true
  discover:
    find:
      command:
        - sh
        - "-c"
        - "find . -name '*.yaml' | xargs -I {} grep \"<path\\|avp\\.kubernetes\\.io\" {} | grep ."
  generate:
    command:
      - argocd-vault-plugin
      - generate
      - "."
  lockRepo: false
EOC
    "avp-helm.yaml" = <<EOC
apiVersion: argoproj.io/v1alpha1
kind: ConfigManagementPlugin
metadata:
  name: argocd-vault-plugin-helm
spec:
  allowConcurrency: true
  init:
    command:
      - sh
      - "-c"
      - "helm dependency build"
  discover:
    find:
      command:
        - sh
        - "-c"
        - "find . -name 'Chart.yaml' && find . -name 'values.yaml'"
  generate:
    command:
      - sh
      - "-c"
      - |
        helm template $ARGOCD_APP_NAME --include-crds -n $ARGOCD_APP_NAMESPACE ${ARGOCD_ENV_HELM_ARGS} . |
        argocd-vault-plugin generate -s vault-configuration -
  lockRepo: false
EOC
  }
}
