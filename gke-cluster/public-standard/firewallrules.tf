# Firewall Rule: SSH
resource "google_compute_firewall" "gke_fw_ssh" {
  name = "gke-fwrule-allow-ssh22"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  #network       = google_compute_network.myvpc.id 
  #network       = data.terraform_remote_state.vpc.outputs.network_name  
  network = data.terraform_remote_state.vpc.outputs.vpc_network_self_link
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-ssh-tag"]
}

# Firewall Rule: HTTP Port 80
resource "google_compute_firewall" "gke_fw_http" {
  name = "gke-fwrule-allow-http80"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  #network       = google_compute_network.myvpc.id 
  #network       = data.terraform_remote_state.vpc.outputs.network_name
  network       = data.terraform_remote_state.vpc.outputs.vpc_network_self_link
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bation-webserver-tag"]
}
# Firewall Rule: Allow All Access
resource "google_compute_firewall" "bation_fw_allow_all" {
  name          = "gke-fwrule-allow-all"
  direction     = "INGRESS"
  #network       = data.terraform_remote_state.vpc.outputs.network_name
  network = data.terraform_remote_state.vpc.outputs.vpc_network_self_link
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  target_tags = ["gke-allow-all-tag"]
}