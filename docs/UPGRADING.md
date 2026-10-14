# Maintenance and upgrade guide

This module starts with Terraform >= 1.7 and `hetznercloud/hcloud ~> 1.70`.
The test matrix covers Terraform 1.7.5/1.16.6 and OpenTofu 1.8.8/1.13.1.
These are module compatibility tests; older engines are not necessarily in the provider's own supported test matrix.

## Before upgrading

Back up your root configuration's state and commit its dependency lock file. Update the module version,
run `terraform init -upgrade` (or `tofu init -upgrade`), and review the plan before applying it.
Child module lock files do not constrain a consuming root configuration.
Keep caller-supplied map keys stable to retain resource addresses.
Unknown object properties may be discarded by Terraform's object conversion; check input property names.

## Checks

Run `terraform init -backend=false`, `terraform validate`, and `terraform test` (or equivalent `tofu`
commands). Initialize and validate each example and submodule separately. Tests use mock providers;
no cloud credentials are needed and no real infrastructure is created.
Before release, check creation, a second no-change plan, updates, and teardown in a disposable Hetzner
project. Mocks do not verify live API behavior, quotas, or capacity.

## Provider coverage maintenance

Formr generates the [schema report](SCHEMA.md). With the module initialized,
run `formr schema . -o docs/SCHEMA.md` and `formr check . --report docs/SCHEMA.md`.
Use the same engine and provider selections recorded in the report's provenance.
The default policy checks inventory completeness and unresolved analysis. Strict interface coverage
and exception annotations are not yet implemented, so a passing check does not approve omitted fields.
Provider configuration belongs in the consuming root configuration; IDs and other computed attributes
are provider-managed rather than creation inputs.

Regenerate README inputs/outputs with `terraform-docs -c .github/linters/.terraform-docs.yml .`.

## Assignment ownership

All supported resource inputs are exposed. SDK `id` attributes are provider-managed, not creation inputs.
Separate assignments derive `floating_ip_id` from the matching `ips` key and accept `server_id` as input.
Unassigned IPs need `home_location`. Inline `server_id` remains supported, but cannot coexist with a
separate assignment for that IP. A separate assignment does not manage guest operating-system networking.

Switching between inline and separate assignment is an ownership migration. Review the plan carefully
and import an existing assignment using its Floating IP ID into
`module.<name>.hcloud_floating_ip_assignment.current["<key>"]` when adopting it.
Keep the IP key stable and remove its inline `server_id` when switching to separate management.
There is no automatic moved block between an IP resource and its assignment resource.
Check assignment changes, a second no-change plan, and removal independently during live testing.
