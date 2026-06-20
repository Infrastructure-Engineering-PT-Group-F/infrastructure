locals {
  workload_identity_pool = "${var.project_id}.svc.id.goog"
}

data "google_service_account" "gke_node_pool" {
  project    = var.project_id
  account_id = var.gke_node_pool_sa_account_id
}

resource "google_container_cluster" "platform" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.zone

  deletion_protection = var.cluster_deletion_protection

  release_channel {
    channel = var.release_channel
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.platform.self_link
  subnetwork = google_compute_subnetwork.platform.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = local.workload_identity_pool
  }
}

resource "google_container_node_pool" "primary" {
  project  = var.project_id
  name     = var.node_pool_name
  location = google_container_cluster.platform.location
  cluster  = google_container_cluster.platform.name

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  node_config {
    machine_type = var.node_machine_type
    image_type   = "COS_CONTAINERD"
    disk_type    = "pd-balanced"
    disk_size_gb = var.node_boot_disk_size_gb
    spot         = false

    service_account = data.google_service_account.gke_node_pool.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
