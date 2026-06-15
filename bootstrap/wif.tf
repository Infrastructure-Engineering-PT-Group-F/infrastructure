resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"

  # Added repository_owner to the mapping
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  # Allow any repository within our GitHub Organization
  attribute_condition = "attribute.repository_owner == 'Infrastructure-Engineering-PT-Group-F'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# -------------------------------------------------------------------------
# Repository-Specific Impersonation Rules
# -------------------------------------------------------------------------

# ONLY the IaC repo can assume the Terraform Automation SA
resource "google_service_account_iam_member" "iac_repo_terraform_impersonation" {
  service_account_id = google_service_account.terraform.name # From service_account.tf
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/Infrastructure-Engineering-PT-Group-F/infrastructure"
}

# (Optional: We would create a new GSA here for pushing to Artifact Registry,
# and bind it to the backend/frontend repositories so their pipelines can push images).