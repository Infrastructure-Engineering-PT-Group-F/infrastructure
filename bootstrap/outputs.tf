output "terraform_service_account_email" {
  description = "Email of the Terraform automation service account (impersonated by the root module)."
  value       = google_service_account.terraform.email
}

output "state_bucket_name" {
  description = "Name of the GCS bucket holding remote Terraform state."
  value       = google_storage_bucket.tfstate.name
}
