provider "google" {
  credentials = var.google_credentials
  project     = var.project_id
  region      = var.region
}
