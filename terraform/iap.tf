resource "google_iap_client" "main" {
  count        = var.enable_iap ? 1 : 0
  brand        = "projects/${data.google_project.current.number}/brands/${data.google_project.current.number}"
  display_name = "GKE Gateway controller by Terraform"
  depends_on   = [google_project_service.main, google_container_cluster.gke]
}
