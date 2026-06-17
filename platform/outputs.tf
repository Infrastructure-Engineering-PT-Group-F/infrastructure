output "vpc_self_link" {
  description = "Self-link of the platform VPC."
  value       = google_compute_network.platform.self_link
}

output "subnet_self_link" {
  description = "Self-link of the platform subnet."
  value       = google_compute_subnetwork.platform.self_link
}

output "pods_range_name" {
  description = "Name of the secondary range for pod IPs."
  value       = "pods"
}

output "services_range_name" {
  description = "Name of the secondary range for service IPs."
  value       = "services"
}

output "nat_router_name" {
  description = "Name of the Cloud Router hosting Cloud NAT for outbound egress."
  value       = google_compute_router.platform.name
}

output "nat_name" {
  description = "Name of the Cloud NAT gateway providing outbound egress."
  value       = google_compute_router_nat.platform.name
}

output "cluster_name" {
  description = "Name of the GKE Standard cluster."
  value       = google_container_cluster.platform.name
}

output "cluster_location" {
  description = "Zonal location of the GKE Standard cluster."
  value       = google_container_cluster.platform.location
}

output "node_pool_name" {
  description = "Name of the dedicated managed node pool."
  value       = google_container_node_pool.primary.name
}

output "workload_identity_pool" {
  description = "Workload Identity pool configured for Kubernetes service accounts."
  value       = google_container_cluster.platform.workload_identity_config[0].workload_pool
}

output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed."
  value       = var.argocd_namespace
}

output "argocd_helm_release_name" {
  description = "Name of the Terraform-managed ArgoCD Helm release."
  value       = helm_release.argocd.name
}

output "argocd_apps_helm_release_name" {
  description = "Name of the Terraform-managed argocd-apps Helm release."
  value       = helm_release.argocd_apps.name
}

output "argocd_root_application_name" {
  description = "Name of the Terraform-managed ArgoCD root Application."
  value       = var.argocd_root_application_name
}

output "argocd_port_forward_command" {
  description = "Local command for temporary ArgoCD UI access without exposing ArgoCD publicly."
  value       = "kubectl -n ${var.argocd_namespace} port-forward svc/argocd-server 8080:443"
}
