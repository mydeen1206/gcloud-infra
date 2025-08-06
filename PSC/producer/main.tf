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
    prefix = "backend/psc/producer"
  } 
}
provider "google" {
  project = "devops-467611"
  region  = "europe-west1"
}


resource "google_compute_network" "producer_vpc_terraform" {
  name                    = "producer-vpc-terraform"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "producer_subnet_terraform" {
  name          = "producer-subnet-terraform"
  ip_cidr_range = "10.100.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.producer_vpc_terraform.id
}
resource "google_compute_subnetwork" "psc_nat_subnet" {
  name          = "psc-nat-subnet"
  ip_cidr_range = "10.200.0.0/24" 
  region        = "europe-west1"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "PRODUCER"
  network       = google_compute_network.producer_vpc_terraform.id
  description   = "PSC subnet for service attachment NAT"
}
# Allow SSH from anywhere
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.producer_vpc_terraform.name

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
  description   = "Allow SSH access from anywhere"
}

# Allow all traffic (use with caution)
resource "google_compute_firewall" "allow_all" {
  name    = "allow-all"
  network = google_compute_network.producer_vpc_terraform.name

  direction = "INGRESS"
  priority  = 1001

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-all"]
  description   = "Allow all traffic (not recommended for production)"
}


resource "google_compute_instance_template" "producer_template_terraform" {
  name         = "producer-template-terraform"
  machine_type = "e2-medium"

  network_interface {
    network    = google_compute_network.producer_vpc_terraform.id
    subnetwork = google_compute_subnetwork.producer_subnet_terraform.id
  }

  metadata_startup_script = <<-EOF
    #! /bin/bash
    sudo apt update -y
    sudo apt install iputils-ping -y
    sudo apt install -y telnet
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo chmod -R 755 /var/www/html
    sudo mkdir -p /var/www/html/app1
    HOSTNAME=$(hostname)
    sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p> Cloud DEMO </p> </body></html>" | sudo tee /var/www/html/app1/index.html
    sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>WebVM App1 </h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>VM IP Address:</strong> $(hostname -I)</p> <p><strong>Application Version:</strong> V1</p> <p>Cloud Platform </p> </body></html>" | sudo tee /var/www/html/index.html
    sudo systemctl restart nginx
  EOF

  #tags = ["http-server"]
  tags = ["http-server", "ssh-access", "allow-all"]

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-11"
  }
}

resource "google_compute_region_instance_group_manager" "producer_igm" {
  name               = "producer-igm"
  region             = "europe-west1"
  base_instance_name = "producer"
  version {
    instance_template = google_compute_instance_template.producer_template_terraform.id
  }
  target_size = 2
}

resource "google_compute_health_check" "tcp_health_check" {
  name               = "tcp-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  tcp_health_check {
    port = 80
  }
}

resource "google_compute_region_backend_service" "producer_backend" {
  name                  = "producer-backend-terraform"
  region                = "europe-west1"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.tcp_health_check.id]

  backend {
    group = google_compute_region_instance_group_manager.producer_igm.instance_group
    balancing_mode  = "CONNECTION"
  }
}

resource "google_compute_forwarding_rule" "psc_forwarding_rule" {
  name                  = "psc-forwarding-rule"
  region                = "europe-west1"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  ports                 = ["80"]
  backend_service       = google_compute_region_backend_service.producer_backend.id
  subnetwork            = google_compute_subnetwork.producer_subnet_terraform.id
  network               = google_compute_network.producer_vpc_terraform.id
}

resource "google_compute_service_attachment" "psc_service_attachment" {
  name                 = "producerserviceterraform"
  region               = "europe-west1"
  target_service       = google_compute_forwarding_rule.psc_forwarding_rule.id
  connection_preference = "ACCEPT_AUTOMATIC"
  enable_proxy_protocol = true

  nat_subnets = [google_compute_subnetwork.psc_nat_subnet.id]
}
