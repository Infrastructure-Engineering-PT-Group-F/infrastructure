variable "project_id" {
  description = "GCP project ID the platform is provisioned into."
  type        = string
}

variable "tf_sa_account_id" {
  description = "Account ID of the Terraform automation SA created by the bootstrap module."
  type        = string
  default     = "terraform-automation"
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Default GCP zone."
  type        = string
  default     = "europe-west1-b"
}
