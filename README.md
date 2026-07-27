# adp-az-tf-envtemplate-standard

Cookiecutter template for generating ADP Azure Terragrunt infrastructure repositories.

## Quick Start

```powershell
# Create and activate a virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

## Usage

Generate a client repo (defaults to `client_config.contoso.json`):

```powershell
python generate.py --overwrite
```

Use a different client config:

```powershell
python generate.py --config client_config.acme.json --overwrite
```

Override specific values via CLI flags:

```powershell
python generate.py --client-name acme --tenant-id "..." --subscription-id "..." --overwrite
```

Output lands in `./output/<project_slug>/`.

## Client Config

All configuration lives in a single JSON file (e.g. `client_config.contoso.json`).

### Top-level parameters

| Parameter | Description | Example |
|---|---|---|
| `project_slug` | Output repository name | `alz-contoso-adp-infra` |
| `client_name` | Client identifier used in resource names | `contoso` |
| `tenant_id` | Azure tenant ID | `00000000-...` |
| `subscription_id` | Azure subscription ID | `00000000-...` |
| `state_resource_group` | Resource group for Terraform state storage | `rg-contoso-state` |
| `state_storage_account` | Storage account for Terraform state | `stcontosostate` |
| `state_container` | Blob container for Terraform state | `tfstate` |
| `env_to_region_map` | Per-environment, per-region configuration | see below |

### env_to_region_map structure

Each environment/region entry is organized into sections:

```json
{
  "dev": {
    "swedencentral": {
      "location_short": "sc",

      "features": {
        "create_lz_vending": true,
        "create_aks": true,
        "create_identities": true,
        "create_postgres": false,
        "create_azure_policy": false
      },

      "aks": {
        "kubernetes_version": "1.35.5",
        "aks_node_vm_size": "Standard_D2s_v3",
        "aks_node_min_count": "2",
        "aks_node_max_count": "5",
        "aks_private_dns_zone": "",
        "aks_admin_group_object_id": "00000000-..."
      },

      "networking": {
        "vnet_cidr": "10.20.0.0/16",
        "aks_subnet_cidr": "10.20.0.0/22",
        "vnet_resource_id": "/subscriptions/.../virtualNetworks/vnet-dev-sc"
      },

      "scopes": {
        "controlplane_dns_scope": "/resourceGroups/.../privateDnsZones/...",
        "dns_zone_scope": "/resourceGroups/.../privateDnsZones/...",
        "key_vault_scope": "/resourceGroups/.../vaults/...",
        "storage_account_scope": "/resourceGroups/.../storageAccounts/..."
      }
    }
  }
}
```

### Feature flags

Feature flags control which modules are enabled per environment:

| Flag | Module | Default |
|---|---|---|
| `create_lz_vending` | Landing zone vending (resource groups, subnets, identities) | `true` |
| `create_aks` | AKS cluster | `true` |
| `create_identities` | Workload identities with federated credentials | `true` |
| `create_postgres` | PostgreSQL Flexible Server | `false` |
| `create_azure_policy` | Azure Policy assignments | `false` |

## How token replacement works

Template files use `__TOKEN__` placeholders (e.g. `__KUBERNETES_VERSION__`, `__VNET_CIDR__`).

The post-gen hook flattens all nested config sections into a single dict, then for each key:

```
config key "vnet_cidr" → uppercased → wrapped → __VNET_CIDR__
```

To add a new templated value:
1. Add the key to the appropriate section in your client config
2. Use `__KEY_NAME__` in the relevant blueprint file

Top-level cookiecutter vars (`tenant_id`, `subscription_id`, `client_name`) are also available as tokens (`__TENANT_ID__`, etc.).

## What gets generated

```
<project_slug>/
├── root.hcl                  # Provider config, remote state, default tags
├── subscription.hcl          # Subscription ID
├── _catalog/                 # Shared module definitions
│   ├── aks/
│   ├── azure-policy/
│   ├── lz-vending/
│   └── postgresql/
└── adp/
    └── <env>/<region>/       # Per-environment leaf folders
        ├── environment.hcl   # Feature flags, env name, tags
        ├── region.hcl        # Location info
        ├── lz-vending/       # VNet, subnets, identities
        ├── aks/              # AKS cluster
        ├── azure-policy/     # Policy assignments
        └── postgresql/       # PostgreSQL (if enabled)
```

Each leaf folder contains a `terragrunt.hcl` (includes the catalog module) and a `values.yaml` (environment-specific configuration).

## Creating a new client config

```powershell
Copy-Item client_config.contoso.json client_config.newclient.json
# Edit the new file with real values
python generate.py --config client_config.newclient.json --overwrite
```
