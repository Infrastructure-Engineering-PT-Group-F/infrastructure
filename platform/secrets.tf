# -------------------------------------------------------------------------
# Tenant Runtime Secret Sources
# -------------------------------------------------------------------------
# Secret Manager containers for tenant runtime credentials that cannot be
# auto-generated because they are externally issued:
#   - avwx-api-key: AVWX weather API token consumed by the backend
#   - ghcr-pull:    GHCR token used to pull the private frontend image
#
# Only the empty containers and least-privilege IAM are defined here. The
# values are seeded out-of-band per the assignment's secrets-management
# allowance and are never committed to Git or stored in Terraform state.
# Delivery to tenant namespaces is handled by ESO (gitops#67).

resource "google_secret_manager_secret" "avwx_api_key" {
  project   = var.project_id
  secret_id = "avwx-api-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "ghcr_pull" {
  project   = var.project_id
  secret_id = "ghcr-pull"

  replication {
    auto {}
  }
}

# Least-privilege read access for the External Secrets Operator SA, scoped per
# secret rather than project-wide.
resource "google_secret_manager_secret_iam_member" "avwx_eso_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.avwx_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.external_secrets_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "ghcr_eso_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.ghcr_pull.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.external_secrets_sa.email}"
}
