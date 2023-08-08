resource "google_compute_security_policy" "main" {
  name = "${local.gke_cluster_name}-security-policy"

  rule {
    action   = "allow"
    priority = 10000

    match {
      expr {
        expression = "has(request.headers['x-secret-key']) && request.headers['x-secret-key'] == \"SECRET\""
      }
    }
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule, higher priority overrides it"
  }

  depends_on = [google_project_service.main]
}
