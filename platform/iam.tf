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

resource "google_service_account" "external_secrets_sa" {
  project      = var.project_id
  account_id   = "external-secrets-sa"
  display_name = "External Secrets Operator Workload Identity SA"
  description  = "Identity for External Secrets Operator to read Google Secret Manager secrets through GKE Workload Identity."
}

resource "google_service_account_iam_binding" "external_secrets_wi_binding" {
  service_account_id = google_service_account.external_secrets_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
  ]
}

# -------------------------------------------------------------------------
# Platform Add-on DNS Identities
# -------------------------------------------------------------------------
resource "google_service_account" "external_dns_sa" {
  project      = var.project_id
  account_id   = "external-dns-sa"
  display_name = "ExternalDNS Workload Identity SA"
  description  = "Identity for ExternalDNS to manage records in the delegated Cloud DNS zone."
}

resource "google_service_account_iam_binding" "external_dns_wi_binding" {
  service_account_id = google_service_account.external_dns_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"
  ]
}

resource "google_project_iam_member" "external_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns_sa.email}"
}

resource "google_service_account" "cert_manager_dns01_sa" {
  project      = var.project_id
  account_id   = "cert-manager-dns01-sa"
  display_name = "cert-manager DNS-01 Workload Identity SA"
  description  = "Identity for cert-manager to complete DNS-01 challenges in the delegated Cloud DNS zone."
}

resource "google_service_account_iam_binding" "cert_manager_dns01_wi_binding" {
  service_account_id = google_service_account.cert_manager_dns01_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
  ]
}

resource "google_project_iam_member" "cert_manager_dns01_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager_dns01_sa.email}"
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
