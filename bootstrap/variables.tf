variable "project_id" {
  description = "GCP project ID the platform is provisioned into."
  type        = string
}

variable "region" {
  description = "GCP region for the Terraform state bucket (single region for cost; independent of the platform cluster region)."
  type        = string
  default     = "europe-west1"
}

variable "state_bucket_name" {
  description = "Globally-unique name of the GCS bucket holding remote Terraform state. Recommended: \"<project_id>-tfstate\"."
  type        = string
}

variable "tf_sa_account_id" {
  description = "Account ID for the Terraform automation service account."
  type        = string
  default     = "terraform-automation"
}

variable "gke_node_pool_sa_account_id" {
  description = "Account ID for the dedicated GKE node-pool service account."
  type        = string
  default     = "gke-node-pool-sa"
}

variable "crossplane_gcp_sa_account_id" {
  description = "Account ID for the Crossplane Google service account managed by the platform module."
  type        = string
  default     = "crossplane-sa"
}

variable "external_dns_sa_account_id" {
  description = "Account ID for the ExternalDNS Google service account managed by the platform module."
  type        = string
  default     = "external-dns-sa"
}

variable "cert_manager_dns01_sa_account_id" {
  description = "Account ID for the cert-manager DNS-01 Google service account managed by the platform module."
  type        = string
  default     = "cert-manager-dns01-sa"
}

variable "tf_sa_roles" {
  description = "Project roles granted to the Terraform SA. Grown per issue (least privilege)."
  type        = list(string)
  default = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
    "roles/dns.admin",                  # Manages the delegated Cloud DNS zone.
    "roles/monitoring.dashboardEditor", # Manages the Cloud Monitoring dashboard (platform/monitoring.tf).
  ]
}

variable "operator_members" {
  description = "IAM members allowed to impersonate the Terraform SA, e.g. \"user:alice@example.com\"."
  type        = list(string)
}
