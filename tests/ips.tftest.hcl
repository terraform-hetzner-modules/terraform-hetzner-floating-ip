mock_provider "hcloud" {
  mock_resource "hcloud_floating_ip" { defaults = { id = "42", ip_address = "192.0.2.1", ip_network = "2001:db8::/64" } }
}

run "empty_collection" {
  command = apply
  assert {
    condition     = length(output.ips) == 0 && length(output.ids) == 0
    error_message = "An empty IP map must create no resources."
  }
}

run "multiple_ips_and_label_overrides" {
  command = apply
  variables {
    labels = { environment = "shared", managed_by = "terraform" }
    ips = {
      ipv4 = { type = "ipv4", home_location = "fsn1" }
      ipv6 = { type = "ipv6", home_location = "hel1", name = "public-v6", labels = { environment = "production" }, delete_protection = false }
    }
  }
  assert {
    condition     = keys(output.ids) == ["ipv4", "ipv6"] && output.names.ipv4 == "ipv4" && output.names.ipv6 == "public-v6"
    error_message = "Multiple IPs must retain caller keys and name overrides."
  }
  assert {
    condition     = output.labels.ipv6.environment == "production" && output.labels.ipv6.managed_by == "terraform" && output.labels.ipv4.environment == "shared"
    error_message = "Per-IP labels must override shared defaults without losing other labels."
  }
  assert {
    condition     = output.ips.ipv4.delete_protection && !output.ips.ipv6.delete_protection && output.ips.ipv6.home_location == "hel1" && output.ip_addresses.ipv4 == "192.0.2.1" && output.ip_networks.ipv6 == "2001:db8::/64"
    error_message = "Protection, location, addresses, and IPv6 networks must be preserved."
  }
}

run "retain_and_rename_one_ip" {
  command = apply
  variables { ips = { ipv4 = { type = "ipv4", home_location = "fsn1", name = "renamed" } } }
  assert {
    condition     = keys(output.ips) == ["ipv4"] && output.names.ipv4 == "renamed"
    error_message = "Removing other IPs and renaming an IP must preserve its caller key."
  }
}

run "reject_invalid_type" {
  command = plan
  variables { ips = { invalid = { type = "ipv5", home_location = "fsn1" } } }
  expect_failures = [var.ips]
}

run "reject_missing_location_and_server" {
  command = plan
  variables { ips = { invalid = { type = "ipv4" } } }
  expect_failures = [var.ips]
}

run "separate_assignments" {
  command = apply
  variables {
    ips = {
      ipv4  = { type = "ipv4", home_location = "fsn1", description = "Public service" }
      ipv6  = { type = "ipv6", home_location = "fsn1" }
      spare = { type = "ipv4", home_location = "fsn1" }
    }
    assignments = { ipv4 = { server_id = 123 }, ipv6 = { server_id = 456 } }
  }
  assert {
    condition     = keys(output.assignments) == ["ipv4", "ipv6"] && output.assignments.ipv4.floating_ip_id == tonumber(output.ids.ipv4) && output.assignment_server_ids.ipv6 == 456 && output.ips.ipv4.description == "Public service"
    error_message = "Assignments must select the managed IP by key and leave other IPs unassigned."
  }
}

run "reassign_and_detach" {
  command = apply
  variables {
    ips = {
      ipv4  = { type = "ipv4", home_location = "fsn1" }
      ipv6  = { type = "ipv6", home_location = "fsn1" }
      spare = { type = "ipv4", home_location = "fsn1" }
    }
    assignments = { ipv4 = { server_id = 789 } }
  }
  assert {
    condition     = keys(output.assignments) == ["ipv4"] && output.assignment_server_ids.ipv4 == 789 && length(output.ips) == 3
    error_message = "Assignments must change independently while preserving the IP collection."
  }
}

run "inline_assignment" {
  command = apply
  variables { ips = { inline = { type = "ipv4", server_id = 123 } } }
  assert {
    condition     = output.ips.inline.server_id == 123 && length(output.assignments) == 0
    error_message = "Inline assignment must remain available without a separate assignment resource."
  }
}

run "reject_unknown_ip_key" {
  command = plan
  variables { assignments = { missing = { server_id = 123 } } }
  expect_failures = [hcloud_floating_ip_assignment.current]
}

run "reject_competing_assignments" {
  command = plan
  variables {
    ips         = { conflicting = { type = "ipv4", home_location = "fsn1", server_id = 123 } }
    assignments = { conflicting = { server_id = 456 } }
  }
  expect_failures = [hcloud_floating_ip.current]
}
