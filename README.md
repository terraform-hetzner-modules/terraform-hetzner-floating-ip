# Hetzner Floating IP Terraform module

Manage multiple IPv4 and IPv6 Floating IPs with shared labels and optional server assignments.

## Usage

Copy this configuration into `main.tf` and add the
[provider configuration](#provider-configuration) below in `versions.tf`.

```hcl
module "floating_ips" {
  source = "terraform-hetzner-modules/floating-ip/hetzner"

  ips = {
    web = { type = "ipv4", home_location = "fsn1" }
  }
}
```

The address is allocated independently of a server. Use `module.floating_ips.ip_addresses.web` to
reference it, and add an assignment when a target server is available.

## Provider configuration

Export your Hetzner API token as `HCLOUD_TOKEN`. Put the following in your calling root's `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.70"
    }
  }
}

provider "hcloud" {}
```

With both files in place, run `terraform init`, `terraform plan`, and `terraform apply`.
Credentials and provider configuration belong in the calling root.
Terraform >= 1.7 and OpenTofu >= 1.8 are supported.

## Examples

- [Basic](examples/basic): independent address allocation.
- [Full](examples/full): every IP setting, inline assignments, and separate assignments.

## Managing multiple IPs

One invocation manages the entire `ips` map; an empty map creates no IPs.
Map keys are stable resource addresses and must be known during planning. Names default to these keys;
renaming an IP through `name` preserves its address. Per-IP labels override shared `labels`.
The `ids`, `names`, `ip_addresses`, `ip_networks`, and `labels` outputs use the same keys.
The `ips` output exposes the complete provider resource objects. Both IPv4 and IPv6 are supported.
Deletion protection defaults to true and can be overridden for each IP.

## Assignments

The `assignments` map creates `hcloud_floating_ip_assignment` resources. Its keys refer to entries in
`ips`, so each IP has at most one separate assignment:

```hcl
module "ips" {
  source = "terraform-hetzner-modules/floating-ip/hetzner"
  ips = {
    web   = { type = "ipv4", home_location = "fsn1" }
    spare = { type = "ipv4", home_location = "fsn1" }
  }
  assignments = {
    web = { server_id = module.server.id }
  }
}
```

Only `web` is assigned; `spare` remains independently allocated. Map keys must be known during planning,
while server IDs may be computed. Removing an assignment unassigns the IP without deleting the IP resource.
The `assignments` output exposes the relationship attributes; `assignment_server_ids` returns server IDs
by IP key. Use these outputs for separately managed associations: the IP resource's own `server_id`
can reflect its last refresh, before a separate assignment was applied.

For direct assignment through the IP resource, use `ips.<key>.server_id` instead. The module rejects
using both forms for the same IP. Separate assignments require `home_location` because the IP must
exist before it can be assigned. With inline `server_id`, location may be inferred by Hetzner.
Changing type or home location replaces the IP. A separate assignment must be the sole owner of that
IP's association, including resources outside this module.

The target server must have a Primary IP of the same family and be in the same network zone and project.
See [Hetzner's Floating IP overview](https://docs.hetzner.com/cloud/floating-ips/overview/) for assignment constraints.
Hetzner assignment configures routing; also configure the Floating IP inside the server using the
[operating-system configuration guide](https://docs.hetzner.com/cloud/floating-ips/persistent-configuration/).
The [full example](examples/full) demonstrates allocation and assignment only.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.7 |
| hcloud | ~> 1.70 |

## Providers

| Name | Version |
| ---- | ------- |
| hcloud | ~> 1.70 |

## Resources

| Name | Type |
| ---- | ---- |
| [hcloud_floating_ip.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip) | resource |
| [hcloud_floating_ip_assignment.current](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/floating_ip_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| assignments | Separate assignments keyed by entries in ips. Each value supplies server\_id; omit that IP's inline server\_id to avoid competing ownership. Keys must be known during planning, but server IDs may be computed. | `map(object({ server_id = number }))` | `{}` | no |
| ips | Floating IPs keyed by stable identifiers. Names default to map keys. Set home\_location for independent IPs, or server\_id for inline assignment. | ```map(object({ name = optional(string) type = string home_location = optional(string) server_id = optional(number) description = optional(string) delete_protection = optional(bool, true) labels = optional(map(string), {}) }))``` | `{}` | no |
| labels | Labels shared by all IPs. Per-IP labels take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| assignment\_server\_ids | Server IDs managed by separate assignments, indexed by IP key. |
| assignments | Complete separate assignment attributes indexed by IP key. Use these for managed assignment state rather than the IP resource's last-refreshed server\_id. |
| ids | IP IDs indexed by the caller's stable keys. |
| ip\_addresses | IP addresses indexed by the caller's stable keys. |
| ip\_networks | IPv6 networks indexed by the caller's stable keys. |
| ips | Complete IP resource attributes indexed by the caller's stable keys. |
| labels | Merged labels indexed by the caller's stable keys. |
| names | IP names indexed by the caller's stable keys. |
<!-- END_TF_DOCS -->

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for local checks and contribution guidelines, and
[UPGRADING.md](docs/UPGRADING.md) for compatibility and live acceptance checks. The generated
[schema report](docs/SCHEMA.md) documents provider coverage and intentional omissions.

## Authors

Maintained by [Terraform Hetzner Modules](https://github.com/terraform-hetzner-modules).
See [AUTHORS](.github/AUTHORS) and [CODEOWNERS](.github/CODEOWNERS).

## License

MIT. See [LICENSE](LICENSE).
