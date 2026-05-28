resource "google_service_account" "terraform" {
  project      = var.project_id
  account_id   = var.tf_sa_account_id
  display_name = "Terraform automation (least-privilege provisioner)"
  depends_on   = [google_project_service.iam]
}

# Project roles granted incrementally per issue — never roles/owner or roles/editor.
resource "google_project_iam_member" "terraform_roles" {
  for_each = toset(var.tf_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform.email}"
}

# Keyless impersonation: operators mint short-lived tokens for the SA.
resource "google_service_account_iam_member" "operators_token_creator" {
  for_each           = toset(var.operator_members)
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
  depends_on         = [google_project_service.iamcredentials]
}
