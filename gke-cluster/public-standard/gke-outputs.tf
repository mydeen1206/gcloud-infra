# Terraform Outputs
output "gke_cluster_name" {
  description = "GKE cluster name"
  value = google_container_cluster.gke_cluster.name
}

output "gke_cluster_location" {
  description = "GKE Cluster location"
  value = google_container_cluster.gke_cluster.location
}

output "gke_cluster_endpoint" {
  description = "GKE Cluster Endpoint"
  value = google_container_cluster.gke_cluster.endpoint
}

output "gke_cluster_master_version" {
  description = "GKE Cluster master version"
  value = google_container_cluster.gke_cluster.master_version
}

output "gke_cluster_ca_certificate" {
  description = "GKE Cluster CA Certificate (Base64)"
  value       = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
}

output "gke_cluster_network" {
  description = "VPC Network used by GKE cluster"
  value       = google_container_cluster.gke_cluster.network
}
output "gke_cluster_subnetwork" {
  description = "Subnetwork used by GKE cluster"
  value       = google_container_cluster.gke_cluster.subnetwork
}