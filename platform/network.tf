resource "google_compute_network" "platform" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
}

# Reserve a range for Google-managed private services such as Cloud SQL.
resource "google_compute_global_address" "private_services_access" {
  project       = var.project_id
  name          = "google-managed-services-${var.vpc_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", var.private_services_access_cidr)[0]
  prefix_length = tonumber(split("/", var.private_services_access_cidr)[1])
  network       = google_compute_network.platform.id
}

resource "google_service_networking_connection" "private_services_access" {
  network                 = google_compute_network.platform.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_access.name]
}

resource "google_compute_subnetwork" "platform" {
  name          = "${var.vpc_name}-${var.region}"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.platform.id
  ip_cidr_range = var.subnet_cidr

  # Lets GKE nodes reach Google APIs without external IPs.
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}
