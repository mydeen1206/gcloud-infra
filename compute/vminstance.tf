data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = "terraform-bucket-devops"  
    prefix = "backend/vpc"                
  }
}

resource "google_compute_instance" "bastion" {
  name         = "${local.name}-bastion"
  machine_type = var.machine_type
  zone         = "us-central1-a"
  tags         = ["allow-ssh", "allow-http", "allow-all"]

  labels = {
    environment = "dev"
    role        = "bastion"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = "20"
      type  = "pd-standard"
    }
    auto_delete = true
  }

  metadata_startup_script = file("${path.module}/app1-webserver-install.sh")

  network_interface {
    subnetwork = data.terraform_remote_state.vpc.outputs.subnets_ids[0]
    access_config {}
  }
}
output "bastion_external_ip" {
  description = "Bastion Host External IP"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}