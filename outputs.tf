output "ips" {
  description = "Complete IP resource attributes indexed by the caller's stable keys."
  value       = hcloud_floating_ip.current
}

output "ids" {
  description = "IP IDs indexed by the caller's stable keys."
  value       = { for key, ip in hcloud_floating_ip.current : key => ip.id }
}

output "names" {
  description = "IP names indexed by the caller's stable keys."
  value       = { for key, ip in hcloud_floating_ip.current : key => ip.name }
}

output "ip_addresses" {
  description = "IP addresses indexed by the caller's stable keys."
  value       = { for key, ip in hcloud_floating_ip.current : key => ip.ip_address }
}

output "ip_networks" {
  description = "IPv6 networks indexed by the caller's stable keys."
  value       = { for key, ip in hcloud_floating_ip.current : key => ip.ip_network }
}

output "labels" {
  description = "Merged labels indexed by the caller's stable keys."
  value       = { for key, ip in hcloud_floating_ip.current : key => ip.labels }
}

output "assignments" {
  description = "Complete separate assignment attributes indexed by IP key. Use these for managed assignment state rather than the IP resource's last-refreshed server_id."
  value       = hcloud_floating_ip_assignment.current
}

output "assignment_server_ids" {
  description = "Server IDs managed by separate assignments, indexed by IP key."
  value       = { for key, assignment in hcloud_floating_ip_assignment.current : key => assignment.server_id }
}
