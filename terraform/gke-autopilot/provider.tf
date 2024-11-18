provider "google" {
  credentials = var.google_credentials
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = var.google_credentials
  project     = var.project_id
  region      = var.region
}
