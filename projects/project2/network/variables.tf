# Input Variables
# GCP Project
variable "gcp_project" {
  description = "Project in which GCP Resources to be created"
  type = string
  default = "devops-467611"
}

# GCP Region
variable "gcp_region2" {
  description = "Region in which GCP Resources to be created"
  type = string
  default = "asia-south1"
}