resource "google_compute_router" "platform" {
  name    = "${var.vpc_name}-router-${var.region}"
  project = var.project_id
  region  = var.region
  network = google_compute_network.platform.id
}

resource "google_compute_router_nat" "platform" {
  name                               = "${var.vpc_name}-nat-${var.region}"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.platform.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
