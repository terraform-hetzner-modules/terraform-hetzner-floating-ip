output "ips" {
  description = "Managed IP attributes by caller key."
  value       = module.ips.ips
}

output "assignments" {
  description = "Assigned IPs and their target servers."
  value       = module.ips.assignments
}
