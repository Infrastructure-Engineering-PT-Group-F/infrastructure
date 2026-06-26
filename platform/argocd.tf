locals {
  # ArgoCD health assessment for Crossplane composite resources. Without it
  # ArgoCD treats these custom kinds as Healthy on apply, so a never-Ready XR
  # (e.g. a Cloud SQL instance stuck creating) is invisible and does not gate
  # sync-wave progression. Reads the Crossplane Synced/Ready conditions.
  crossplane_health_lua = <<-EOF
    hs = {}
    if obj.status ~= nil and obj.status.conditions ~= nil then
      local synced = nil
      local ready = nil
      for _, c in ipairs(obj.status.conditions) do
        if c.type == "Synced" then synced = c end
        if c.type == "Ready" then ready = c end
      end
      if synced ~= nil and synced.status == "False" then
        hs.status = "Degraded"
        hs.message = synced.message or synced.reason or "Synced=False"
        return hs
      end
      if ready ~= nil and ready.status == "True" then
        hs.status = "Healthy"
        hs.message = ready.message or "Ready"
        return hs
      end
      if ready ~= nil then
        hs.status = "Progressing"
        hs.message = ready.message or ready.reason or "Not ready"
        return hs
      end
    end
    hs.status = "Progressing"
    hs.message = "Waiting for resource to report status"
    return hs
  EOF
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  create_namespace = true

  repository = var.argocd_chart_repository
  chart      = var.argocd_chart_name
  version    = var.argocd_chart_version
  skip_crds  = false
  timeout    = 600

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

  values = [
    yamlencode({
      configs = {
        cm = {
          "resource.customizations.health.argoproj.io_Application"               = <<-EOF
            hs = {}
            if obj.status ~= nil then
              if obj.status.health ~= nil then
                hs.status = obj.status.health.status
                if obj.status.health.message ~= nil then
                  hs.message = obj.status.health.message
                end
                return hs
              end
            end
            hs.status = "Progressing"
            hs.message = "Waiting for Application to report health"
            return hs
          EOF
          "resource.customizations.health.platform.fh-burgenland.at_SQLInstance" = local.crossplane_health_lua
          "resource.customizations.health.platform.fh-burgenland.at_XTenant"     = local.crossplane_health_lua
        }
      }
    })
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
      projects = {
        platform = {
          namespace   = var.argocd_namespace
          description = "Restricted project for the platform App-of-Apps and add-ons."
          sourceRepos = [
            var.gitops_repo_url,
            "https://charts.jetstack.io",
            "docker.io/envoyproxy",
            "https://kubernetes-sigs.github.io/external-dns/",
            "https://charts.external-secrets.io",
            "https://charts.crossplane.io/stable",
          ]
          destinations = [
            {
              server    = "https://kubernetes.default.svc"
              namespace = "*"
            },
          ]
          clusterResourceWhitelist = [
            {
              group = "*"
              kind  = "*"
            },
          ]
          namespaceResourceWhitelist = [
            {
              group = "*"
              kind  = "*"
            },
          ]
          orphanedResources = {
            warn = true
          }
        }
      }
      applications = {
        (var.argocd_root_application_name) = {
          namespace = var.argocd_namespace
          finalizers = [
            "resources-finalizer.argocd.argoproj.io",
          ]
          project = "platform"
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
