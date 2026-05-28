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

variable "vpc_name" {
  description = "Name of the platform VPC."
  type        = string
  default     = "vpc-platform"
}

variable "subnet_cidr" {
  description = "Primary CIDR for the GKE node subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pod IPs (VPC-native alias IPs)."
  type        = string
  default     = "10.10.0.0/16"
}

variable "services_cidr" {
  description = "Secondary range for GKE service IPs (VPC-native alias IPs)."
  type        = string
  default     = "10.20.0.0/20"
}
