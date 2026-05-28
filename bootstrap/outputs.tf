output "terraform_service_account_email" {
  description = "Email of the Terraform automation service account (impersonated by the root module)."
  value       = google_service_account.terraform.email
}
