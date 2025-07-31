# GCP Project
variable "gcp_project1" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = "terraform-467505"
}
variable "gcp_project2" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = "devops-467611"
}

# GCP Region
variable "gcp_region1" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = "us-central1"
}