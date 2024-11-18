resource "google_project_service" "enable_services" {
  for_each = toset([
    "aiplatform.googleapis.com",
    "cloudbuild.googleapis.com",
    "eventarc.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iamcredentials.googleapis.com"
  ])

  project = var.project_id
  service = each.value
}