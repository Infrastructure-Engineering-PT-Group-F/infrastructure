resource "google_compute_network" "platform" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  mtu                     = 1460
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
