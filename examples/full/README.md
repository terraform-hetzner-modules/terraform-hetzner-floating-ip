# Full floating ip example

The IPv4 and IPv6 service addresses use separate `assignments`. A spare address stays unassigned,
and an additional IPv4 address uses inline `server_id` with location inferred from the server.
These models can coexist for different addresses, but each address has only one association owner.

This example allocates and assigns addresses. Configure the additional addresses inside the server's
operating system separately. Review deletion protection before removing the protected addresses.

## Running the example

Export `HCLOUD_TOKEN`, supply the inputs described in `variables.tf`, then run:

```shell
terraform init
terraform plan
terraform apply
```

This creates real infrastructure. Review the plan and any deletion protection before cleanup.
See the [module README](../../README.md) for usage and input descriptions.
