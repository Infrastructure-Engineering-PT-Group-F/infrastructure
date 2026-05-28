locals {
  terraform_service_account = "${var.tf_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = local.terraform_service_account
}
