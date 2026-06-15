locals {
  terraform_service_account = "${var.tf_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"
}

provider "google" {
  project                     = var.project_id
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = local.terraform_service_account
}

data "google_client_config" "current" {}

provider "helm" {
  kubernetes = {
    host                   = "https://${google_container_cluster.platform.endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.platform.master_auth[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.platform.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.platform.master_auth[0].cluster_ca_certificate)
}
