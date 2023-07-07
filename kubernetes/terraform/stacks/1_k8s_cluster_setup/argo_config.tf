resource "kubernetes_secret" "secret_argocd_github_repo" {
  metadata {
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
    name      = "github-repo"
    namespace = "argocd"
  }
  data = {
    "name"          = "IaC"
    "project"       = "default"
    "type"          = "git"
    "url"           = "git@github.com:acm-uic/IaC.git"
    "sshPrivateKey" = var.deploy_key
  }
}

resource "kubernetes_manifest" "application_cluster_config" {
  depends_on = [helm_release.argocd]
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "iac"
      "namespace" = "argocd"
    }
    "spec" = {
      "project" = "default"
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "source" = {
        "repoURL"        = "git@github.com:acm-uic/IaC.git"
        "targetRevision" = "HEAD"
        "path"           = "kubernetes/argocd/stacks/common"
        "directory" = {
          "recurse" = true
          "jsonnet" = {}
        }
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}
