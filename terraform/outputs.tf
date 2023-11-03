output "cluster_name" {
  value       = google_container_cluster.default.name
  description = "Cluster name"
}

output "dns_zone_name_servers" {
  value       = google_dns_managed_zone.default.name_servers
  description = "Write these virtual name servers in your base domain."
}
