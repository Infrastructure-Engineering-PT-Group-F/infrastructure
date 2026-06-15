# -------------------------------------------------------------------------
# Infrastructure Tooling Identities
# -------------------------------------------------------------------------
resource "google_service_account" "gitops_gcp_sa" {
  project      = var.project_id
  account_id   = "gitops-sa"
  display_name = "GitOps Workload Identity SA"
}

resource "google_service_account_iam_binding" "gitops_wi_binding" {
  service_account_id = google_service_account.gitops_gcp_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[gitops-system/gitops-ksa]"
  ]
}

resource "google_service_account" "crossplane_gcp_sa" {
  project      = var.project_id
  account_id   = "crossplane-sa"
  display_name = "Crossplane Workload Identity SA"
}

resource "google_service_account_iam_binding" "crossplane_wi_binding" {
  service_account_id = google_service_account.crossplane_gcp_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[crossplane-system/provider-gcp]"
  ]
}

# -------------------------------------------------------------------------
# Application Workload Identities
# -------------------------------------------------------------------------
resource "google_service_account" "backend_app_sa" {
  project      = var.project_id
  account_id   = "backend-app-sa"
  display_name = "Backend Application SA"
  description  = "Identity for the backend pods to securely access GCP resources (e.g., Cloud SQL)."
}

resource "google_service_account_iam_binding" "backend_wi_binding" {
  service_account_id = google_service_account.backend_app_sa.name
  role               = "roles/iam.workloadIdentityUser"

  # This KSA will be deployed later via the gitops-repo when installing the backend app
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[application-namespace/backend-ksa]"
  ]
}

resource "google_service_account" "frontend_app_sa" {
  project      = var.project_id
  account_id   = "frontend-app-sa"
  display_name = "Frontend Application SA"
  description  = "Identity for frontend pods, should they need GCP API access."
}

resource "google_service_account_iam_binding" "frontend_wi_binding" {
  service_account_id = google_service_account.frontend_app_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[application-namespace/frontend-ksa]"
  ]
}