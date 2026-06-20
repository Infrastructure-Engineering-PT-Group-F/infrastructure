output "terraform_service_account_email" {
  description = "Email of the Terraform automation service account (impersonated by the root module)."
  value       = google_service_account.terraform.email
}

output "gke_node_pool_sa_email" {
  description = "Email of the dedicated GKE node-pool service account."
  value       = google_service_account.gke_node_pool.email
}

output "state_bucket_name" {
  description = "Name of the GCS bucket holding remote Terraform state."
  value       = google_storage_bucket.tfstate.name
}

output "github_actions_wif_provider" {
  description = "Full resource name of the GitHub Actions WIF provider. Use as `workload_identity_provider` in google-github-actions/auth."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}
