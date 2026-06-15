output "vpc_self_link" {
  description = "Self-link of the platform VPC. Consumed by #9 (GKE cluster)."
  value       = google_compute_network.platform.self_link
}

output "subnet_self_link" {
  description = "Self-link of the platform subnet. Consumed by #9."
  value       = google_compute_subnetwork.platform.self_link
}

output "pods_range_name" {
  description = "Name of the secondary range for pod IPs. Consumed by #9."
  value       = "pods"
}

output "services_range_name" {
  description = "Name of the secondary range for service IPs. Consumed by #9."
  value       = "services"
}

output "nat_router_name" {
  description = "Name of the Cloud Router hosting Cloud NAT for outbound egress #28."
  value       = google_compute_router.platform.name
}

output "nat_name" {
  description = "Name of the Cloud NAT gateway providing egress for GHCR image pulls #28."
  value       = google_compute_router_nat.platform.name
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

output "backend_app_sa_email" {
  description = "Email of the backend application's GCP service account."
  value       = google_service_account.backend_app_sa.email
}

output "frontend_app_sa_email" {
  description = "Email of the frontend application's GCP service account."
  value       = google_service_account.frontend_app_sa.email
}
