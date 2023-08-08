locals {
  gke_nodepool = {
    roles = [
      "roles/logging.logWriter",
      "roles/cloudtrace.agent",
    ]
  }
}

resource "google_service_account" "gke_nodepool" {
  project      = data.google_project.current.project_id
  account_id   = local.gke_cluster_name
  display_name = local.gke_cluster_name
  depends_on   = [google_project_service.main]
}

resource "google_project_iam_member" "gke_nodepool" {
  for_each = toset(local.gke_nodepool.roles)
  project  = data.google_project.current.project_id
  member   = "serviceAccount:${google_service_account.gke_nodepool.email}"
  role     = each.value
}
