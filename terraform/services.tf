locals {
  project_services = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "endpoints.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iap.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

resource "google_project_service" "main" {
  for_each                   = toset(local.project_services)
  project                    = data.google_project.current.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}
