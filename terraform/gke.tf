locals {
  gke_cluster_name = "gke-gtw-test"
  gke_config = {
    network = {
      primary_ip_range              = "10.10.0.0/16"
      master_ipv4_cidr_block        = "172.16.0.0/28"
      cluster_secondary_range_name  = "gke-pods"
      cluster_secondary_ip_range    = "10.11.0.0/16"
      services_secondary_range_name = "gke-services"
      services_secondary_ip_range   = "10.12.0.0/20"
    }
  }
}

resource "google_container_cluster" "gke" {
  project            = data.google_project.current.project_id
  name               = local.gke_cluster_name
  location           = var.region
  initial_node_count = 1

  ## Network Config
  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke_tokyo.id

  ip_allocation_policy {
    cluster_secondary_range_name  = local.gke_config.network.cluster_secondary_range_name
    services_secondary_range_name = local.gke_config.network.services_secondary_range_name
  }
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "from internet"
      cidr_block   = "0.0.0.0/0"
    }
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_global_access_config {
      enabled = true
    }
    master_ipv4_cidr_block      = local.gke_config.network.master_ipv4_cidr_block
  }

  ## Security Config
  workload_identity_config {
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "19:00"
    }
  }

  ## Monitoring Config
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  enable_shielded_nodes = true

  node_config {
    disk_size_gb    = 50
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_nodepool.email
    oauth_scopes    = ["cloud-platform", "userinfo-email"]
    tags            = ["gke"]
    spot            = true
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${self.name} --region=${self.location} --project=${self.project}"
  }
}

resource "google_container_node_pool" "gke" {
  project            = data.google_project.current.project_id
  cluster            = google_container_cluster.gke.name
  name               = "additional-nodepool"
  location           = google_container_cluster.gke.location
  initial_node_count = 0

  autoscaling {
    max_node_count = 3
    min_node_count = 0
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    disk_size_gb    = 50
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_nodepool.email
    oauth_scopes    = ["cloud-platform", "userinfo-email"]
    tags            = ["gke"]
    spot            = true
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }
}
