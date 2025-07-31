output "vpc_network_name" {
  value = module.vpc.network_name
}

output "vpc_network_self_link" {
  value = module.vpc.network_self_link
}

output "subnets_names" {
  value = module.vpc.subnets_names
}

output "subnets_self_links" {
  value = module.vpc.subnets_self_links
}

output "subnets_ids" {
  value = module.vpc.subnets_ids
}

output "subnets_ips" {
  value = module.vpc.subnets_ips
}

output "subnets_regions" {
  value = module.vpc.subnets_regions
}
output "vpc_id" {
  value = module.vpc.network_id
}
output "ssh_firewall_rule_name" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.fw_ssh.name
}

output "http_firewall_rule_name" {
  description = "Name of the HTTP firewall rule"
  value       = google_compute_firewall.fw_http.name
}

output "allow_all_firewall_rule_name" {
  description = "Name of the allow-all firewall rule"
  value       = google_compute_firewall.fw_allow_all.name
}

output "vpc_network_id" {
  description = "VPC network ID associated with the firewall rules"
  value       = module.vpc.network_id
}
