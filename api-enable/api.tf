# Terraform Settings Block
terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-bucket-devops"
    prefix = "backend/api"
  }
}

# Main Provider (Default Project)
provider "google" {
  project = var.gcp_project1
  region  = var.gcp_region1
}

# Secondary Provider (Second Project) — MUST use alias
provider "google" {
  alias   = "project2"
  project = var.gcp_project2
  region  = var.gcp_region1
}

# Enable APIs in Project 1
resource "google_project_service" "required_apis_project1" {
  for_each = toset([
    "compute.googleapis.com",      # Required by Kubernetes
    "container.googleapis.com",    # Kubernetes Engine
    "dns.googleapis.com"           # Cloud DNS
  ])

  project             = var.gcp_project1
  service             = each.value
  disable_on_destroy  = false
}

# Enable APIs in Project 2
resource "google_project_service" "required_apis_project2" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com"
  ])

  provider            = google.project2
  project             = var.gcp_project2
  service             = each.value
  disable_on_destroy  = false
}
