resource "hcloud_floating_ip" "current" {
  for_each = var.ips

  name              = coalesce(each.value.name, each.key)
  type              = each.value.type
  home_location     = each.value.home_location
  server_id         = each.value.server_id
  description       = each.value.description
  delete_protection = each.value.delete_protection
  labels            = merge(var.labels, each.value.labels)

  lifecycle {
    precondition {
      condition     = !contains(keys(var.assignments), each.key) || each.value.server_id == null
      error_message = "An IP cannot use both inline server_id and a separate assignment."
    }
  }
}

resource "hcloud_floating_ip_assignment" "current" {
  for_each = var.assignments

  floating_ip_id = hcloud_floating_ip.current[each.key].id
  server_id      = each.value.server_id

  lifecycle {
    precondition {
      condition     = contains(keys(var.ips), each.key)
      error_message = "Each assignment key must reference an entry in ips."
    }
  }
}
