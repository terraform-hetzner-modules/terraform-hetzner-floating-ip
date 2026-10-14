<p align="center">
    <!-- terraform-hetzner-floating-ip -->
<img src="https://cdn.simpleicons.org/terraform/844FBA" alt="Terraform Logo" align="center" width="128">
<img src="https://avatars.githubusercontent.com/u/30047064?s=200&v=4" alt="Hetzner Logo" align="center" width="128">
    <h1 align="center">Hetzner Cloud</h1>
    <h2 align="center"><code>floating-ip</code></h2>
</p>

[![License](https://img.shields.io/github/license/terraform-hetzner-modules/terraform-hetzner-floating-ip?label=License)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-_>=_1.7-brightgreen?logo=terraform&logoColor=623CE4)][terraform]
[![Opentofu](https://img.shields.io/badge/OpenTofu-_>=_1.8-brightgreen?logo=opentofu)][opentofu]
[![CI Status](https://github.com/terraform-hetzner-modules/terraform-hetzner-floating-ip/actions/workflows/testing.yaml/badge.svg)](https://github.com/terraform-hetzner-modules/terraform-hetzner-floating-ip/blob/main/.github/workflows/testing.yaml)
[![GitHub Release](https://img.shields.io/github/v/release/terraform-hetzner-modules/terraform-hetzner-floating-ip?label=Release)][github_releases]
[![GitHub Activity](https://img.shields.io/github/commit-activity/m/terraform-hetzner-modules/terraform-hetzner-floating-ip?label=Commits)][github_commits]
[![Renovate](https://img.shields.io/badge/Renovate-enabled-brightgreen?logo=renovate&logoColor=1A1F6C)][renovate]
[![Pre-Commit](https://img.shields.io/badge/PreCommit-enabled-brightgreen?logo=precommit&logoColor=FAB040)][pre-commit]

A [Terraform module][module] to manage a collection of Floating IPs in [Hetzner Cloud][hetzner].

## ✨ TL;DR

```hcl
module "ips" {
  source = "terraform-hetzner-modules/floating-ip/hetzner"

  labels = { managed_by = "terraform" }
  ips = {
    public_v4 = { type = "ipv4", home_location = "fsn1" }
    public_v6 = { type = "ipv6", home_location = "fsn1", name = "web-v6" }
  }
}
```

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

## Compatibility and examples

Requires Terraform >= 1.7 (OpenTofu >= 1.8 tested) and hcloud ~> 1.70.
See [basic](examples/basic) and [full](examples/full) examples; configure credentials through `HCLOUD_TOKEN`.
The generated [schema report](docs/SCHEMA.md) records provider fields and module mappings.
See the [maintenance and upgrade guide](docs/UPGRADING.md) for validation and coverage checks.
Run `terraform init -backend=false`, `terraform validate`, and `terraform test`
for credential-free validation and mocked tests.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.70 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_assignments"></a> [assignments](#input\_assignments) | Separate assignments keyed by entries in ips. Each value supplies server\_id; omit that IP's inline server\_id to avoid competing ownership. Keys must be known during planning, but server IDs may be computed. | `map(object({ server_id = number }))` | `{}` | no |
| <a name="input_ips"></a> [ips](#input\_ips) | Floating IPs keyed by stable identifiers. Names default to map keys. Set home\_location for independent IPs, or server\_id for inline assignment. | ```map(object({ name = optional(string) type = string home_location = optional(string) server_id = optional(number) description = optional(string) delete_protection = optional(bool, true) labels = optional(map(string), {}) }))``` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels shared by all IPs. Per-IP labels take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_assignment_server_ids"></a> [assignment\_server\_ids](#output\_assignment\_server\_ids) | Server IDs managed by separate assignments, indexed by IP key. |
| <a name="output_assignments"></a> [assignments](#output\_assignments) | Complete separate assignment attributes indexed by IP key. Use these for managed assignment state rather than the IP resource's last-refreshed server\_id. |
| <a name="output_ids"></a> [ids](#output\_ids) | IP IDs indexed by the caller's stable keys. |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | IP addresses indexed by the caller's stable keys. |
| <a name="output_ip_networks"></a> [ip\_networks](#output\_ip\_networks) | IPv6 networks indexed by the caller's stable keys. |
| <a name="output_ips"></a> [ips](#output\_ips) | Complete IP resource attributes indexed by the caller's stable keys. |
| <a name="output_labels"></a> [labels](#output\_labels) | Merged labels indexed by the caller's stable keys. |
| <a name="output_names"></a> [names](#output\_names) | IP names indexed by the caller's stable keys. |
<!-- END_TF_DOCS -->

### 🔃 Contributing

Refer to our [documentation for contributors][contributing] for contributing guidelines, commit message
formats and versioning tips.

### 📥 Maintainers

This project is owned and maintained by [Terraform Hetzner Modules][org]. Refer to the [`AUTHORS`][authors] or [`CODEOWNERS`][owners]
for more information. You may also use the linked contact details to reach out directly.

### ©️ Copyright

- _Assets provided by:_ **[HashiCorp][hashicorp]**
- _Sources provided by:_ **[Terraform Hetzner Modules][org]** under the **[MIT License][license]**

<!-- INTERNAL REFERENCES -->

<!-- Project references -->

<!-- File references -->

[license]: LICENSE
[contributing]: docs/CONTRIBUTING.md
[authors]: .github/AUTHORS
[owners]: .github/CODEOWNERS

<!-- General links -->

[org]: https://github.com/terraform-hetzner-modules
[terraform]: https://terraform.io
[opentofu]: https://opentofu.org/
[hashicorp]: https://www.hashicorp.com/
[hetzner]: https://hetzner.com
[github_releases]: https://github.com/terraform-hetzner-modules/terraform-hetzner-floating-ip/releases
[github_commits]: https://github.com/terraform-hetzner-modules/terraform-hetzner-floating-ip/commits/main/

<!-- Third-party -->

[module]: https://registry.terraform.io/modules/terraform-hetzner-modules/floating-ip/hetzner/latest
[renovate]: https://renovatebot.com/
[pre-commit]: https://pre-commit.com/
