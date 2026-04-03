# terraform-ovh-valkey

> Terraform module to create and manage a **Valkey** (Redis-compatible) database on OVHcloud Public Cloud.

## Design decisions

- OVHcloud-focused and intentionally opinionated
- Valkey-only to avoid unsafe generic database abstractions
- Network creation is out of scope — must be handled by a dedicated network module
- Designed to be orchestrated by higher-level tools such as Ansible

## Usage

### Minimal (public network)

```hcl
module "valkey" {
  source  = "git::https://gitlab.com/theobs-digital/terraform-ovh-valkey.git?ref=v1.0.0"

  service_name   = "your-ovh-project-id"
  valkey_version = "8.1"
  valkey_plan    = "essential"
  valkey_flavor  = "b3-8"

  valkey_nodes = [
    { region = "GRA" },
    { region = "GRA" },
  ]

  create_valkey_users = false
}
```

### With vRack (private network) and users

```hcl
module "valkey" {
  source  = "git::https://gitlab.com/theobs-digital/terraform-ovh-valkey.git?ref=v1.0.0"

  service_name       = "your-ovh-project-id"
  valkey_version     = "8.1"
  valkey_plan        = "business"
  valkey_flavor      = "b3-8"
  valkey_description = "Production Valkey cluster"
  valkey_disk_size   = 100

  valkey_nodes = [
    {
      region     = "GRA"
      network_id = "pn-xxxxxx"
      subnet_id  = "subnet-yyyyyy"
    },
    {
      region     = "GRA"
      network_id = "pn-xxxxxx"
      subnet_id  = "subnet-yyyyyy"
    },
  ]

  valkey_ip_restrictions = [
    { ip = "10.0.0.0/24", description = "Internal network" },
  ]

  valkey_users = [
    {
      name       = "app"
      categories = ["+@all"]
      channels   = ["*"]
      commands   = ["+@all"]
      keys       = ["*"]
    },
  ]
}
```

See [examples/basic](examples/basic/) and [examples/complete](examples/complete/) for more.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ovh"></a> [ovh](#requirement\_ovh) | >= 1.0, < 2.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_ovh"></a> [ovh](#provider\_ovh) | 1.8.0 |

### Resources

| Name | Type |
|------|------|
| [ovh_cloud_project_database.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database) | resource |
| [ovh_cloud_project_database_valkey_user.user](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_database_valkey_user) | resource |

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `service_name` | OVH project service name (project ID) | `string` |
| `valkey_flavor` | Valkey flavor (e.g. b3-8) | `string` |
| `valkey_nodes` | List of Valkey nodes (minimum 2 for HA) | `list(object({ region = string network_id = optional(string) subnet_id = optional(string) }))` |
| `valkey_plan` | Valkey plan (essential, business, enterprise) | `string` |
| `valkey_version` | Valkey engine version (e.g. 7.2, 8.1) | `string` |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_valkey_users` | Enable or disable Valkey user creation | `bool` | `true` |
| `valkey_advanced_configuration` | Advanced Valkey configuration (Redis-compatible key/value pairs) | `map(string)` | `null` |
| `valkey_backup_regions` | List of regions where backups are stored | `list(string)` | `null` |
| `valkey_backup_time` | Backup time in HH:MM format (UTC) | `string` | `null` |
| `valkey_deletion_protection` | Enable deletion protection | `bool` | `true` |
| `valkey_description` | Description of the Valkey database | `string` | `null` |
| `valkey_disk_size` | Disk size in GB (optional, OVH default if null) | `number` | `null` |
| `valkey_ip_restrictions` | List of IP restrictions for Valkey access | `list(object({ ip = string description = optional(string) }))` | `null` |
| `valkey_users` | List of Valkey users with ACL configuration | `list(object({ name = string categories = list(string) channels = list(string) commands = list(string) keys = list(string) }))` | `[]` |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `valkey_endpoints` | Valkey endpoints | no |
| `valkey_engine` | Database engine | no |
| `valkey_id` | Valkey database ID | no |
| `valkey_nodes` | Valkey nodes configuration | no |
| `valkey_status` | Current Valkey database status | no |
| `valkey_users` | Created Valkey users | **yes** |
| `valkey_version` | Valkey version | no |
<!-- END_TF_DOCS -->

## Validations

The module enforces the following rules at `terraform plan` time:

| Variable | Rule |
|----------|------|
| `valkey_version` | Must match format `X.Y` |
| `valkey_plan` | Must be `essential`, `business`, or `enterprise` |
| `valkey_nodes` | Minimum 2 nodes |
| `valkey_disk_size` | Positive integer when set |
| `valkey_backup_time` | `HH:MM` format when set |
| `valkey_users` | Names must be unique |

## Tests

Native Terraform tests cover **input variable validation** only. They run in a separate root (`tests/variables-only/`) so no OVH API credentials or provider plugins are required—unlike `terraform test` at the module root, which would load `main.tf` and the OVH provider.

That directory contains:

- `main.tf` — minimal `terraform` block (no resources)
- `variables.tf` — symlink to the repository root `variables.tf` (keeps rules identical)
- `basic.tftest.hcl` — test runs (defaults, `expect_failures` for invalid inputs)

**Recommended:** from the repository root, run:

```bash
make test
```

This runs `terraform init -backend=false` and `terraform test` in `tests/variables-only`.

**Manual equivalent:**

```bash
terraform -chdir=tests/variables-only init -backend=false
terraform -chdir=tests/variables-only test
```

**Symlinks:** on systems where Git does not check out symlinks as links, replace `tests/variables-only/variables.tf` with a copy of the root `variables.tf`.

**CI:** use `make test` or the `-chdir=tests/variables-only` commands above. A bare `terraform test` at the module root does not run this suite (it would report zero tests from `tests/*.tftest.hcl` and is not used for variable checks).

**Validate:** `make validate` runs `terraform validate` in `tests/variables-only/` (same layout as tests—no OVH resources), so it succeeds in CI without credentials. Validating the **module root** (`terraform validate` at the repository root) may fail if the installed `ovh/ovh` version does not yet expose the resources and arguments used in `main.tf`; fix that by upgrading the provider constraint/lockfile when OVH publishes a matching schema.

## Contributing

Install local tooling on **macOS** (requires [Homebrew](https://brew.sh/)):

```bash
make install
```

That installs **tflint**, **terraform-docs**, and **pre-commit**, and runs `tflint --init`. On Linux or without Homebrew, install those tools from your package manager or the upstream links in the [Makefile](Makefile) `install` target, then run `tflint --init` in this repository.

This module uses [pre-commit](https://pre-commit.com/) hooks for code quality:

```bash
pre-commit install
pre-commit run -a
```

Other Makefile targets:

```bash
make lint      # terraform fmt -check + tflint
make validate  # terraform validate in tests/variables-only (see Tests → Validate)
make docs      # regenerate README between BEGIN_TF_DOCS / END_TF_DOCS
```

`tflint` and `terraform-docs` must be on your `PATH` for `make lint` and `make docs`. `make validate` only needs Terraform (see **Tests → Validate** above).

## License

See [LICENSE](LICENSE) for details.
