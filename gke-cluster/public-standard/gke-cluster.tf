data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = "terraform-bucket-devops"  
    prefix = "backend/vpc"                
  }
}

# Resource: GKE Cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "${local.name}-gke-cluster"
  location = var.gcp_region1

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  # Network
  #network = google_compute_network.myvpc.self_link
  network = data.terraform_remote_state.vpc.outputs.vpc_network_self_link
  subnetwork = data.terraform_remote_state.vpc.outputs.subnets_self_links[0]
  # In production, change it to true (Enable it to avoid accidental deletion)
  deletion_protection = false
}
