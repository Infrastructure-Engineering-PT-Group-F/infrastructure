# Runtime-critical project IAM grants. These are kept in bootstrap because the
# seed runs with operator ADC and can manage project IAM without giving the
# day-to-day Terraform automation service account broad IAM administration.
resource "google_project_iam_member" "gke_node_pool_default_node_service_account" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_node_pool.email}"

  depends_on = [google_project_service.container]
}

resource "google_project_iam_member" "crossplane_cloudsql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${var.crossplane_gcp_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [google_project_service.sqladmin]
}

resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${var.external_dns_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [google_project_service.dns]
}

resource "google_project_iam_member" "cert_manager_dns01_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${var.cert_manager_dns01_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [google_project_service.dns]
}
