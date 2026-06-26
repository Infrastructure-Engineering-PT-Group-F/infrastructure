resource "google_monitoring_dashboard" "tenant_health" {
  project = var.project_id

  dashboard_json = jsonencode({
    displayName = "Group F - Tenant Health & Resources"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          xPos = 0, yPos = 0, width = 6, height = 4
          widget = {
            title = "Backend scrape up (per tenant)"
            xyChart = {
              dataSets = [{
                plotType        = "LINE"
                timeSeriesQuery = { prometheusQuery = "up{job=\"weather-app-backend\"}" }
              }]
            }
          }
        },
        {
          xPos = 6, yPos = 0, width = 6, height = 4
          widget = {
            title = "Backend HTTP request rate (req/s)"
            xyChart = {
              dataSets = [{
                plotType        = "LINE"
                timeSeriesQuery = { prometheusQuery = "sum by (namespace) (rate(http_server_requests_seconds_count{job=\"weather-app-backend\"}[5m]))" }
              }]
            }
          }
        },
        {
          xPos = 0, yPos = 4, width = 6, height = 4
          widget = {
            title = "Backend JVM heap used (bytes)"
            xyChart = {
              dataSets = [{
                plotType        = "LINE"
                timeSeriesQuery = { prometheusQuery = "sum by (namespace) (jvm_memory_used_bytes{job=\"weather-app-backend\", area=\"heap\"})" }
              }]
            }
          }
        },
        {
          xPos = 6, yPos = 4, width = 6, height = 4
          widget = {
            title = "Tenant container CPU (cores)"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" resource.type=\"k8s_container\" resource.label.\"namespace_name\"=monitoring.regex.full_match(\"tenant-.*\")"
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.label.\"namespace_name\""]
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 0, yPos = 8, width = 6, height = 4
          widget = {
            title = "Tenant container memory used (bytes)"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/memory/used_bytes\" resource.type=\"k8s_container\" resource.label.\"namespace_name\"=monitoring.regex.full_match(\"tenant-.*\")"
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.label.\"namespace_name\""]
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos = 6, yPos = 8, width = 6, height = 4
          widget = {
            title = "Tenant container restarts"
            xyChart = {
              dataSets = [{
                plotType = "LINE"
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/restart_count\" resource.type=\"k8s_container\" resource.label.\"namespace_name\"=monitoring.regex.full_match(\"tenant-.*\")"
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MAX"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.label.\"namespace_name\""]
                    }
                  }
                }
              }]
            }
          }
        },
      ]
    }
  })
}
