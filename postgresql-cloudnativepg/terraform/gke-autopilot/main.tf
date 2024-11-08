#Copyright 2023 Google LLC

#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

# create private subnet
module "network" {
  source         = "../modules/network"
  project_id     = var.project_id
  region         = var.region
  cluster_prefix = var.cluster_prefix
}

# [START gke_databases_postgresql_cloudnativepg_autopilot_private_regional_cluster]
module "postgresql_cluster" {
  source                   = "../modules/cluster-autopilot"
  project_id               = var.project_id
  region                   = var.region
  cluster_prefix           = var.cluster_prefix
  network                  = module.network.network_name
  subnetwork               = module.network.subnet_name
}

output "kubectl_connection_command" {
  value       = "gcloud container clusters get-credentials ${var.cluster_prefix}-cluster --region ${var.region}"
  description = "Connection command"
}
# [END gke_databases_postgresql_cloudnativepg_autopilot_private_regional_cluster]

# Create an Artifact Registry repository
resource "google_artifact_registry_repository" "vector_db_images_repo" {
  project              = var.project_id
  location             = var.region
  repository_id        = "${var.cluster_prefix}-images"
  format               = "DOCKER"
  description          = "Vector database images repository"
}

# Get project details, including the project number
data "google_project" "project" {
  project_id = var.project_id
}

# Grant "roles/storage.objectAdmin" role to the default Compute Engine service account
resource "google_project_iam_member" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant "roles/artifactregistry.admin" role to the default Compute Engine service account
resource "google_project_iam_member" "artifact_registry_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant "roles/artifactregistry.serviceAgent" role to the GKE cluster's service account
resource "google_project_iam_member" "artifact_registry_service_agent" {
  project = var.project_id
  role    = "roles/artifactregistry.serviceAgent"
  member  = "serviceAccount:${module.postgresql_cluster.service_account}"
}
