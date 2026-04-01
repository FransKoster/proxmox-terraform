## Overview

This repository contains a Terraform module for creating Proxmox virtual
machines from a Debian cloud-init template.

The module is built for the Telmate Proxmox provider version `3.0.2-rc07` and
supports:

- Cloning a cloud-init enabled Debian template that already exists on the Proxmox host
- Configuring CPU, memory, disk, tags, pool, and startup behavior
- Defining one or more network interfaces
- Passing cloud-init settings such as `ciuser`, `sshkeys`, DNS, and `ipconfig*`
- Using Proxmox snippets through `cicustom`

## Repository Layout

- `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`: reusable root module
- `examples/basic`: minimal example showing provider setup and module usage

## Prerequisites

Before using this module, make sure Proxmox already has:

- A Debian VM template with cloud-init support enabled
- `qemu-guest-agent` installed in the template if you want Terraform to read the guest IP address
- A storage backend for the VM disk, for example `local-lvm`
- An optional snippets storage if you want to use `cicustom`

## Template Script

The repository includes [scripts/01-create-debian-cloudinit-template.sh](scripts/01-create-debian-cloudinit-template.sh)
to prepare a Debian cloud image VM and convert it to a Proxmox template.

Supported CLI arguments:

- `--vmid` (or `-v`): VM ID to use
- `--action` (or `-a`): `create-image` or `create-template`

Examples:

```bash
# Create the cloud image VM (does not template it)
./scripts/01-create-debian-cloudinit-template.sh --vmid 9000 --action create-image

# Convert an existing VM to template
./scripts/01-create-debian-cloudinit-template.sh --vmid 9000 --action create-template
```

## Module Usage

Example:

```hcl
provider "proxmox" {
	pm_api_url          = var.pm_api_url
	pm_api_token_id     = var.pm_api_token_id
	pm_api_token_secret = var.pm_api_token_secret
}

module "vm" {
	source = "github.com/FransKoster/proxmox-terraform"

	name        = "debian-vm-01"
	target_node = "pve01"
	clone       = "debian-12-cloudinit-template"

	ciuser    = "debian"
	sshkeys   = file("~/.ssh/id_ed25519.pub")
	ipconfig0 = "ip=dhcp"

	boot_disk = {
		storage = "local-lvm"
		size    = "20G"
	}

	networks = [
		{
			id     = 0
			bridge = "vmbr0"
		}
	]
}
```

To use the local example in this repository:

```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```

## Snippet Support

The module exposes the provider's `cicustom` field so that Proxmox snippets can
be used directly.

Example:

```hcl
module "vm" {
	source = "github.com/FransKoster/proxmox-terraform"

	name        = "debian-vm-with-snippet"
	target_node = "pve01"
	clone       = "debian-12-cloudinit-template"
	cicustom    = "user=local:snippets/debian-user-data.yaml"

	boot_disk = {
		storage = "local-lvm"
		size    = "20G"
	}

	networks = [
		{
			id     = 0
			bridge = "vmbr0"
		}
	]
}
```

This matches the Proxmox cloud-init snippet workflow described in the provider
documentation.

## Inputs

The most important module inputs are:

| Name | Description | Default |
| --- | --- | --- |
| `name` | VM name in Proxmox | n/a |
| `target_node` | Proxmox node name | n/a |
| `clone` | Cloud-init enabled template name | n/a |
| `vmid` | Fixed VM ID | `null` |
| `cores` | CPU cores per socket | `2` |
| `sockets` | CPU sockets | `1` |
| `memory` | Memory in MiB | `2048` |
| `boot_disk` | Primary disk definition | see `variables.tf` |
| `additional_disks` | Additional disks | `[]` |
| `networks` | Network interface definitions | `[]` |
| `ciuser` | Cloud-init username | `debian` |
| `cipassword` | Cloud-init password | `null` |
| `sshkeys` | Newline-delimited SSH public keys | `null` |
| `ipconfig0` | Cloud-init network config for `net0` | `ip=dhcp` |
| `cicustom` | Proxmox snippet reference | `null` |
| `nameserver` | DNS server for cloud-init | `null` |
| `searchdomain` | DNS search domain for cloud-init | `null` |
| `tags` | Proxmox tags | `[]` |
| `pool` | Proxmox pool | `null` |
| `vm_state` | Desired VM power state | `running` |

For the full input contract, see `variables.tf`.

## Outputs

The module exports:

- `vm_id`
- `name`
- `target_node`
- `default_ipv4_address`
- `default_ipv6_address`

## Validation

The example configuration has been validated with:

```bash
cd examples/basic
terraform init -backend=false
terraform validate
```

## Provider Reference

- Provider: https://registry.terraform.io/providers/Telmate/proxmox/3.0.2-rc07
- Resource: https://registry.terraform.io/providers/Telmate/proxmox/3.0.2-rc07/docs/resources/vm_qemu
