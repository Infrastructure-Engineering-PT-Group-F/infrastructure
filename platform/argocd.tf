resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  create_namespace = true

  repository = var.argocd_chart_repository
  chart      = var.argocd_chart_name
  version    = var.argocd_chart_version
  skip_crds  = false

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    },
  ]

  depends_on = [
    google_container_node_pool.primary,
    google_compute_router_nat.platform,
  ]
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  namespace = var.argocd_namespace

  repository = var.argocd_chart_repository
  chart      = var.argocd_apps_chart_name
  version    = var.argocd_apps_chart_version

  values = [
    yamlencode({
      applications = {
        (var.argocd_root_application_name) = {
          namespace = var.argocd_namespace
          finalizers = [
            "resources-finalizer.argocd.argoproj.io",
          ]
          project = "default"
          source = {
            repoURL        = var.gitops_repo_url
            targetRevision = var.gitops_target_revision
            path           = var.gitops_root_application_path
            directory = {
              recurse = true
              include = var.gitops_root_application_include
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = var.argocd_namespace
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "ApplyOutOfSyncOnly=true",
            ]
          }
        }
      }
    }),
  ]

  depends_on = [
    helm_release.argocd,
  ]
}
