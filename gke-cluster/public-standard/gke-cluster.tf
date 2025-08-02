# Import VPC outputs from remote state
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = "terraform-bucket-devops"  
    prefix = "backend/vpc"                
  }
}

# GKE Cluster Resource (Control Plane Only)
resource "google_container_cluster" "gke_cluster" {
  name     = "${local.name}-gke-cluster"
  location = var.gcp_region1

  remove_default_node_pool = true  
  initial_node_count       = 1   

  network    = data.terraform_remote_state.vpc.outputs.vpc_network_self_link
  subnetwork = data.terraform_remote_state.vpc.outputs.subnets_self_links[0]

  deletion_protection = false  

  # Recommended additions:
  release_channel {
    channel = "STABLE"  # Options: RAPID, REGULAR, STABLE
  }
  # Optional but useful
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER"]
  }
}
