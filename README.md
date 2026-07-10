# adp-az-tf-envtemplate-standard

Cookiecutter template for generating ADP Azure Terragrunt infrastructure repositories.

## Usage

```bash
cookiecutter https://github.com/itgix/adp-az-tf-envtemplate-standard
```

Or locally:

```bash
cookiecutter /path/to/adp-az-tf-envtemplate-standard
```

## Parameters

| Parameter | Description | Example |
|---|---|---|
| `project_slug` | Output repository name | `alz-contoso-adp-infra` |
| `client_name` | Client identifier used in resource names | `contoso` |
| `tenant_id` | Azure tenant ID | `00000000-...` |
| `subscription_id` | Azure subscription ID | `00000000-...` |
| `state_resource_group` | Resource group for Terraform state storage | `rg-managed-dev-swedencentral` |
| `state_storage_account` | Storage account for Terraform state | `stcontosodevsc` |
| `state_container` | Blob container for Terraform state | `tfstate` |
| `env_to_region_map` | JSON map of environments and regions with per-region config | see below |

## env_to_region_map

Each environment/region entry supports the following keys:

```json
{
  "dev": {
    "swedencentral": {
      "location_short": "sc",
      "vnet_cidr": "10.20.0.0/16",
      "aks_subnet_cidr": "10.20.0.0/22",
      "kubernetes_version": "1.35.5",
      "aks_node_vm_size": "Standard_D2s_v3",
      "aks_node_min_count": "2",
      "aks_node_max_count": "5",
      "aks_private_dns_zone": "",
      "aks_admin_group_object_id": "00000000-..."
    }
  }
}
```

## What gets generated

- Terragrunt catalog modules (`_catalog/adp/`) for AKS, networking, identities, and PostgreSQL
- Per-environment leaf folders (`adp/<env>/<region>/`) with pre-filled `values.yaml` files
- `root.hcl` and `subscription.hcl` wired to the provided state backend and subscription
