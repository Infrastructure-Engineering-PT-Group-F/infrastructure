# Seed runs as the human operator (ADC); only the root module impersonates the SA.
provider "google" {
  project = var.project_id
}
