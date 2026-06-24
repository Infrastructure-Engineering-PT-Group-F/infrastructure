resource "google_service_account" "terraform" {
  project      = var.project_id
  account_id   = var.tf_sa_account_id
  display_name = "Terraform automation (least-privilege provisioner)"
  depends_on   = [google_project_service.iam]
}

resource "google_service_account" "gke_node_pool" {
  project      = var.project_id
  account_id   = var.gke_node_pool_sa_account_id
  display_name = "GKE node pool least-privilege service account"
  description  = "Dedicated service account used by GKE worker nodes instead of the Compute Engine default service account."
  depends_on   = [google_project_service.iam]
}

# Project roles granted incrementally per issue — never roles/owner or roles/editor.
resource "google_project_iam_member" "terraform_roles" {
  for_each = toset(var.tf_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform.email}"
}

# Custom role letting the Terraform SA manage Secret Manager secret containers
# and their IAM, but NOT read secret payloads (no secretmanager.versions.access).
# Values are seeded out-of-band by an operator, so the automation identity never
# needs payload access. See platform/secrets.tf and docs/bootstrap-exceptions.md.
resource "google_project_iam_custom_role" "secret_container_manager" {
  project     = var.project_id
  role_id     = "secretContainerManager"
  title       = "Secret Manager Container Manager"
  description = "Manage Secret Manager secret containers and their IAM, without access to secret payloads."
  permissions = [
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.list",
    "secretmanager.secrets.update",
    "secretmanager.secrets.delete",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.setIamPolicy",
  ]
}

resource "google_project_iam_member" "terraform_secret_container_manager" {
  project = var.project_id
  role    = google_project_iam_custom_role.secret_container_manager.id
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Keyless impersonation: operators mint short-lived tokens for the SA.
resource "google_service_account_iam_member" "operators_token_creator" {
  for_each           = toset(var.operator_members)
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
  depends_on         = [google_project_service.iamcredentials]
}
