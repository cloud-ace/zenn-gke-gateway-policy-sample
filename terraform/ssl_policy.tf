resource "google_compute_ssl_policy" "main" {
  name            = "${local.gke_cluster_name}-policy"
  min_tls_version = "TLS_1_2"
  profile         = "RESTRICTED"
  depends_on      = [google_project_service.main]
}
