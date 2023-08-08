locals {
  service_name = "gke-gateway-${random_string.endpoints_service.result}"
  service_fqdn = "${local.service_name}.endpoints.${var.project_id}.cloud.goog"
  openapi_config = {
    swagger = "2.0"
    info = {
      title       = "GKE Gateway test"
      description = "GKE Gateway test"
      version     = "1.0.0"
    }
    host = local.service_fqdn
    "x-google-endpoints" = [
      {
        name   = local.service_fqdn
        target = google_compute_global_address.gke.address
      }
    ]
    paths = {}
  }
}

resource "random_string" "endpoints_service" {
  length  = 8
  special = false
  upper   = false
}

resource "google_endpoints_service" "gateway" {
  service_name   = local.service_fqdn
  openapi_config = yamlencode(local.openapi_config)
}
