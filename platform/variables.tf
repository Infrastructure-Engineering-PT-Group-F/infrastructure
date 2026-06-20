variable "project_id" {
  description = "GCP project ID the platform is provisioned into."
  type        = string
}

variable "tf_sa_account_id" {
  description = "Account ID of the Terraform automation SA created by the bootstrap module."
  type        = string
  default     = "terraform-automation"
}

variable "gke_node_pool_sa_account_id" {
  description = "Account ID of the dedicated GKE node-pool service account created by the bootstrap module."
  type        = string
  default     = "gke-node-pool-sa"
}

variable "region" {
  description = "Default GCP region for regional Google Cloud APIs used by the platform."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "GCP zone for the zonal GKE Standard cluster."
  type        = string
  default     = "europe-west1-b"
}

variable "cluster_name" {
  description = "Name of the zonal GKE Standard cluster."
  type        = string
  default     = "group-f-platform-gke"
}

variable "release_channel" {
  description = "GKE release channel governing control plane and node auto-upgrade cadence."
  type        = string
  default     = "REGULAR"

  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "release_channel must be one of RAPID, REGULAR, or STABLE."
  }
}

variable "node_pool_name" {
  description = "Name of the dedicated managed node pool for platform worker nodes."
  type        = string
  default     = "primary-pool"
}

variable "node_min_count" {
  description = "Minimum number of worker nodes per zone when the managed node pool autoscales."
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_count >= 1
    error_message = "node_min_count must be at least 1."
  }
}

variable "node_max_count" {
  description = "Maximum number of worker nodes per zone when the managed node pool autoscales."
  type        = number
  default     = 5

  validation {
    condition     = var.node_max_count >= var.node_min_count
    error_message = "node_max_count must be greater than or equal to node_min_count."
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
  default     = false
}

variable "delegated_dns_managed_zone_name" {
  description = "Cloud DNS managed zone name serving gcp.ajdininfrastructure.lol."
  type        = string
  default     = "gcp-ajdininfrastructure-lol"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block used by the GKE control plane for private cluster communication."
  type        = string
  default     = "172.16.0.0/28"
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

variable "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_repository" {
  description = "Helm repository URL for the ArgoCD chart."
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
}

variable "argocd_chart_name" {
  description = "Name of the ArgoCD Helm chart."
  type        = string
  default     = "argo-cd"
}

variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart to install."
  type        = string
  default     = "9.5.17"
}

variable "argocd_apps_chart_name" {
  description = "Name of the Helm chart used to install the ArgoCD root App-of-Apps."
  type        = string
  default     = "argocd-apps"
}

variable "argocd_apps_chart_version" {
  description = "Version of the argocd-apps Helm chart to install."
  type        = string
  default     = "2.0.5"
}

variable "argocd_root_application_name" {
  description = "Name of the ArgoCD root Application created by Terraform."
  type        = string
  default     = "root"
}

variable "gitops_repo_url" {
  description = "Git repository URL reconciled by the ArgoCD root Application."
  type        = string
  default     = "https://github.com/Infrastructure-Engineering-PT-Group-F/gitops.git"
}

variable "gitops_target_revision" {
  description = "Git revision reconciled by the ArgoCD root Application."
  type        = string
  default     = "main"
}

variable "gitops_root_application_path" {
  description = "Path in the GitOps repository containing child ArgoCD Applications."
  type        = string
  default     = "platform"
}
