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
  description = "Default GCP region for regional Google Cloud APIs used by the platform."
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "GCP zone for the zonal GKE Standard cluster."
  type        = string
  default     = "europe-west3-a"
}

variable "cluster_name" {
  description = "Name of the zonal GKE Standard cluster."
  type        = string
  default     = "group-f-platform-gke"
}

variable "node_pool_name" {
  description = "Name of the dedicated managed node pool for platform worker nodes."
  type        = string
  default     = "primary-pool"
}

variable "node_count" {
  description = "Number of worker nodes in the managed node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.node_count >= 1
    error_message = "node_count must be at least 1."
  }
}

variable "node_machine_type" {
  description = "Machine type used by the managed GKE node pool."
  type        = string
  default     = "n2-standard-2"
}

variable "node_boot_disk_size_gb" {
  description = "Balanced Persistent Disk boot disk size in GiB for each node."
  type        = number
  default     = 40

  validation {
    condition     = var.node_boot_disk_size_gb >= 40
    error_message = "node_boot_disk_size_gb must be at least 40."
  }
}

variable "cluster_deletion_protection" {
  description = "Whether Terraform should prevent accidental deletion of the GKE cluster."
  type        = bool
  default     = true
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
