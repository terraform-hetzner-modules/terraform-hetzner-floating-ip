terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.70" }
  }
}

resource "terraform_data" "server_id" { input = 123 }

module "subject" {
  source      = "../.."
  ips         = { computed = { type = "ipv4", home_location = "fsn1" } }
  assignments = { computed = { server_id = terraform_data.server_id.output } }
}

output "names" {
  description = "Names remain known with computed server IDs."
  value       = module.subject.names
}
