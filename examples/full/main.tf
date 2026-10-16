resource "hcloud_server" "example" {
  name        = "floating-ip-example"
  server_type = "cx23"
  image       = "debian-13"
  location    = "fsn1"
}

module "ips" {
  source = "../.."
  labels = { environment = "example", managed_by = "terraform" }
  ips = {
    public_v4 = {
      name              = "service-v4"
      type              = "ipv4"
      home_location     = "fsn1"
      server_id         = null # Owned by assignments below.
      description       = "Service address"
      delete_protection = true
      labels            = { family = "ipv4" }
    }
    public_v6 = { type = "ipv6", home_location = "fsn1", labels = { family = "ipv6" } }
    spare     = { type = "ipv4", home_location = "fsn1" }
    inline = {
      name              = "inline-v4"
      type              = "ipv4"
      home_location     = null # Inferred from the server.
      server_id         = hcloud_server.example.id
      description       = "Inline-assigned address"
      delete_protection = false
      labels            = { assignment = "inline" }
    }
  }
  assignments = {
    public_v4 = { server_id = hcloud_server.example.id }
    public_v6 = { server_id = hcloud_server.example.id }
  }
}
