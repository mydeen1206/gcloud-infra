output "ssh_firewall_rule_name" {
  description = "Target tag used by the SSH firewall rule"
  value       = google_compute_firewall.bation_fw_allow_all.target_tags
}

output "http_firewall_rule_name" {
  description = "Target tag used by the HTTP firewall rule"
  value       = google_compute_firewall.bation_fw_http.target_tags
}

output "allow_all_firewall_rule_name" {
  description = "Target tag used by the allow-all firewall rule"
  value       = google_compute_firewall.bation_fw_allow_all.target_tags
}
output "vpc_network_id" {
  description = "VPC network ID associated with the firewall rules"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

