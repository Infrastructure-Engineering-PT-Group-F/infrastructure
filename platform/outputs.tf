output "vpc_self_link" {
  description = "Self-link of the platform VPC."
  value       = google_compute_network.platform.self_link
}

output "private_services_access_range_name" {
  description = "Name of the reserved Private Services Access range."
  value       = google_compute_global_address.private_services_access.name
}

output "private_services_access_cidr" {
  description = "CIDR reserved for Google Private Services Access."
  value       = var.private_services_access_cidr
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

output "gke_node_pool_sa_email" {
  description = "Email of the dedicated GKE node-pool service account."
  value       = data.google_service_account.gke_node_pool.email
}

output "workload_identity_pool" {
  description = "Workload Identity pool configured for Kubernetes service accounts."
  value       = google_container_cluster.platform.workload_identity_config[0].workload_pool
}

output "delegated_dns_zone_name" {
  description = "Name of the delegated Cloud DNS managed zone."
  value       = google_dns_managed_zone.delegated_platform_zone.name
}

output "monitoring_dashboard_url" {
  description = "Console URL of the tenant health & resources Cloud Monitoring dashboard."
  value       = "https://console.cloud.google.com/monitoring/dashboards/builder/${reverse(split("/", google_monitoring_dashboard.tenant_health.id))[0]}?project=${var.project_id}"
}

output "delegated_dns_name" {
  description = "DNS name served by the delegated Cloud DNS managed zone."
  value       = google_dns_managed_zone.delegated_platform_zone.dns_name
}

output "delegated_dns_name_servers" {
  description = "Authoritative name servers for registrar delegation."
  value       = google_dns_managed_zone.delegated_platform_zone.name_servers
}

# Workload Identity service-account emails
output "gitops_sa_email" {
  description = "Email of the GitOps tool's GCP service account."
  value       = google_service_account.gitops_gcp_sa.email
}

output "crossplane_sa_email" {
  description = "Email of the Crossplane GCP service account."
  value       = google_service_account.crossplane_gcp_sa.email
}

output "external_dns_sa_email" {
  description = "Email of the ExternalDNS GCP service account."
  value       = google_service_account.external_dns_sa.email
}

output "cert_manager_dns01_sa_email" {
  description = "Email of the cert-manager DNS-01 GCP service account."
  value       = google_service_account.cert_manager_dns01_sa.email
}

output "external_secrets_sa_email" {
  description = "Email of the External Secrets Operator GCP service account."
  value       = google_service_account.external_secrets_sa.email
}

output "backend_app_sa_email" {
  description = "Email of the backend application's GCP service account."
  value       = google_service_account.backend_app_sa.email
}

output "frontend_app_sa_email" {
  description = "Email of the frontend application's GCP service account."
  value       = google_service_account.frontend_app_sa.email
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
