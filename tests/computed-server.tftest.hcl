mock_provider "hcloud" {
  mock_resource "hcloud_floating_ip" { defaults = { id = "42", ip_address = "192.0.2.1", ip_network = "2001:db8::/64" } }
}

run "computed_server_id_is_plannable" {
  command = plan
  module { source = "./tests/setup" }
  assert {
    condition     = output.names.computed == "computed"
    error_message = "Computed server IDs must not determine IP or assignment resource addresses."
  }
}
