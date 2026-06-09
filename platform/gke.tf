locals {
  workload_identity_pool = "${var.project_id}.svc.id.goog"
}

resource "google_container_cluster" "platform" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.zone

  deletion_protection = var.cluster_deletion_protection

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.platform.self_link
  subnetwork = google_compute_subnetwork.platform.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = local.workload_identity_pool
  }

  depends_on = [
    google_project_service.compute,
    google_project_service.container,
  ]
}

resource "google_container_node_pool" "primary" {
  project  = var.project_id
  name     = var.node_pool_name
  location = google_container_cluster.platform.location
  cluster  = google_container_cluster.platform.name

  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    image_type   = "COS_CONTAINERD"
    disk_type    = "pd-balanced"
    disk_size_gb = var.node_boot_disk_size_gb
    spot         = false
  }
}
