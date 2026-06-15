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
