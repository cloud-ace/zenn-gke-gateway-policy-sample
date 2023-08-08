resource "google_compute_network" "gke" {
  project                 = data.google_project.current.project_id
  name                    = local.gke_cluster_name
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.main]
}

resource "google_compute_subnetwork" "gke_tokyo" {
  project                  = data.google_project.current.project_id
  network                  = google_compute_network.gke.self_link
  region                   = var.region
  ip_cidr_range            = local.gke_config.network.primary_ip_range
  name                     = local.gke_cluster_name
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.gke_config.network.cluster_secondary_range_name
    ip_cidr_range = local.gke_config.network.cluster_secondary_ip_range
  }
  secondary_ip_range {
    range_name    = local.gke_config.network.services_secondary_range_name
    ip_cidr_range = local.gke_config.network.services_secondary_ip_range
  }
}

resource "google_compute_router" "gke" {
  project = data.google_project.current.project_id
  name    = "${google_compute_subnetwork.gke_tokyo.name}-nat"
  network = google_compute_network.gke.self_link
  region  = google_compute_subnetwork.gke_tokyo.region
}

resource "google_compute_router_nat" "gke" {
  project = data.google_project.current.project_id
  name    = google_compute_router.gke.name
  region  = google_compute_router.gke.region
  router  = google_compute_router.gke.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_global_address" "gke" {
  project    = data.google_project.current.project_id
  name       = "${local.gke_cluster_name}-lb"
  ip_version = "IPV4"
  depends_on = [google_project_service.main]
}

resource "google_compute_managed_ssl_certificate" "gke" {
  project = data.google_project.current.project_id
  name    = "${local.gke_cluster_name}-cert"
  type    = "MANAGED"
  managed {
    domains = [google_endpoints_service.gateway.service_name]
  }
}
