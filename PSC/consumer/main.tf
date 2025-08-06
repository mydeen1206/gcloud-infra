# Terraform Settings Block
terraform {
  required_version = ">= 1.9"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 6.46.0"
             }  
  }
    backend "gcs" {
    bucket = "terraform-bucket-devops"
    prefix = "backend/psc/consumer"
  } 
}


provider "google" {
  project = "terraform-467505"
  region  = "europe-west1"
}

resource "google_compute_network" "consumer_vpc_terraform" {
  name                    = "consumer-vpc-terraform"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer_subnet_terraform" {
  name          = "consumer-subnet"
  ip_cidr_range = "10.100.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.consumer_vpc_terraform.id
}

resource "google_compute_address" "psc_ip" {
  name         = "psc-endpoint-ip"
  region       = "europe-west1"
  subnetwork   = google_compute_subnetwork.consumer_subnet_terraform.id
  address_type = "INTERNAL"
  address      = "10.120.0.2"
}

resource "google_compute_service_connection" "psc_endpoint" {
  name              = "psc-endpoint"
  region            = "europe-west1"
  network           = google_compute_network.consumer_vpc_terraform.id
  subnetwork        = google_compute_subnetwork.consumer_subnet_terraform.id
  address           = google_compute_address.psc_ip.address
  target_service    = "projects/devops-467611/regions/europe-west1/serviceAttachments/producerservice"
}
