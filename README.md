<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/avm-res-containerservice-managedcluster/azurerm | 0.7.1 |
| <a name="module_lz_vending"></a> [lz\_vending](#module\_lz\_vending) | Azure/avm-ptn-alz-sub-vending/azure | 0.3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_private_dns_zone.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.workload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.workload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.aks_apiserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.aks_nodes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_key_vault.eso](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_private_dns_zone.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_user_assigned_identity.kubelet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_admin_group_ids"></a> [aks\_admin\_group\_ids](#input\_aks\_admin\_group\_ids) | List of Azure AD group object IDs that will have admin role on the AKS cluster | `list` | `[]` | no |
| <a name="input_aks_cluster_version"></a> [aks\_cluster\_version](#input\_aks\_cluster\_version) | Desired Kubernetes cluster version | `string` | `"1.36"` | no |
| <a name="input_aks_maintenance_windows"></a> [aks\_maintenance\_windows](#input\_aks\_maintenance\_windows) | Maintenance window configuration for AKS. Leave empty to disable scheduled maintenance. | <pre>map(object({<br/>    name = string<br/>    maintenance_window = object({<br/>      duration_hours = number<br/>      start_time     = string<br/>      utc_offset     = string<br/>      schedule = object({<br/>        weekly = optional(object({<br/>          day_of_week    = string<br/>          interval_weeks = number<br/>        }))<br/>        daily = optional(object({<br/>          interval_days = number<br/>        }))<br/>      })<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_aks_outbound_type"></a> [aks\_outbound\_type](#input\_aks\_outbound\_type) | The outbound (egress) routing method. Possible values: loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway. | `string` | `"loadBalancer"` | no |
| <a name="input_aks_private_cluster"></a> [aks\_private\_cluster](#input\_aks\_private\_cluster) | Whether to make the AKS cluster private. When false, the API server is publicly accessible. | `bool` | `true` | no |
| <a name="input_aks_prometheus_workspace_id"></a> [aks\_prometheus\_workspace\_id](#input\_aks\_prometheus\_workspace\_id) | Azure Monitor Workspace resource ID for managed Prometheus. Set to null to disable. | `any` | `null` | no |
| <a name="input_aks_sku"></a> [aks\_sku](#input\_aks\_sku) | The SKU of the AKS cluster. name: Base or Automatic. tier: Free, Standard, or Premium. | `map` | <pre>{<br/>  "name": "Base",<br/>  "tier": "Free"<br/>}</pre> | no |
| <a name="input_aks_system_pool"></a> [aks\_system\_pool](#input\_aks\_system\_pool) | Configuration for the default system node pool. The vnet\_subnet\_id is injected automatically. | <pre>object({<br/>    name                = string<br/>    vm_size             = string<br/>    os_sku              = string<br/>    availability_zones  = list(string)<br/>    enable_auto_scaling = bool<br/>    min_count           = number<br/>    max_count           = number<br/>    count_of            = number<br/>    os_disk_size_gb     = number<br/>    upgrade_settings = object({<br/>      max_surge = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "availability_zones": [<br/>    "1"<br/>  ],<br/>  "count_of": 1,<br/>  "enable_auto_scaling": true,<br/>  "max_count": 2,<br/>  "min_count": 1,<br/>  "name": "system",<br/>  "os_disk_size_gb": 128,<br/>  "os_sku": "AzureLinux",<br/>  "upgrade_settings": {<br/>    "max_surge": "33%"<br/>  },<br/>  "vm_size": "Standard_B2ms"<br/>}</pre> | no |
| <a name="input_aks_worker_pools"></a> [aks\_worker\_pools](#input\_aks\_worker\_pools) | Map of additional worker node pools. The vnet\_subnet\_id is injected automatically. Leave empty for no worker pools. | <pre>map(object({<br/>    name                = string<br/>    vm_size             = string<br/>    os_sku              = string<br/>    availability_zones  = list(string)<br/>    enable_auto_scaling = bool<br/>    min_count           = number<br/>    max_count           = number<br/>    count_of            = number<br/>    os_disk_size_gb     = number<br/>    mode                = string<br/>    upgrade_settings = object({<br/>      max_surge = string<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_az_subscription_id"></a> [az\_subscription\_id](#input\_az\_subscription\_id) | Azure subscription to deploy resources | `string` | `"f7f8b016-64ca-4d42-afad-de91b2eae685"` | no |
| <a name="input_budget_enabled"></a> [budget\_enabled](#input\_budget\_enabled) | Whether to create subscription budgets | `bool` | `false` | no |
| <a name="input_budgets"></a> [budgets](#input\_budgets) | Map of budget configurations. See lz-vending module docs for schema. | `map` | `{}` | no |
| <a name="input_enable_eso"></a> [enable\_eso](#input\_enable\_eso) | Whether to enable External Secrets Operator integration. When true, looks up existing Key Vault via data and assigns role. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the infrastructure is going to be deployed | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project / client / product to be used in naming convention | `string` | `"contoso"` | no |
| <a name="input_provision_aks"></a> [provision\_aks](#input\_provision\_aks) | Whether to provision the AKS cluster | `bool` | `true` | no |
| <a name="input_provision_controlplane_dns"></a> [provision\_controlplane\_dns](#input\_provision\_controlplane\_dns) | Whether to create the control plane private DNS zone. When false, existing zone is looked up via data. | `bool` | `false` | no |
| <a name="input_provision_identities"></a> [provision\_identities](#input\_provision\_identities) | Whether to create managed identities via lz-vending. When false, existing identities are looked up via data. | `bool` | `true` | no |
| <a name="input_provision_kubelet_identity"></a> [provision\_kubelet\_identity](#input\_provision\_kubelet\_identity) | Whether to create the kubelet identity. When false, an existing identity is looked up via data. | `bool` | `true` | no |
| <a name="input_provision_vnet"></a> [provision\_vnet](#input\_provision\_vnet) | Whether to create a new VNet via lz-vending. When false, subnets are created in existing VNet. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region to deploy to | `string` | `"swedencentral"` | no |
| <a name="input_region_short"></a> [region\_short](#input\_region\_short) | Short region code used in resource names with character limits (e.g. sc for swedencentral, weu for westeurope) | `string` | `"sc"` | no |
| <a name="input_subnet_aks_apiserver_cidr"></a> [subnet\_aks\_apiserver\_cidr](#input\_subnet\_aks\_apiserver\_cidr) | CIDR for the AKS API server subnet - minimum /28 | `string` | `"10.0.4.0/28"` | no |
| <a name="input_subnet_aks_nodes_cidr"></a> [subnet\_aks\_nodes\_cidr](#input\_subnet\_aks\_nodes\_cidr) | CIDR for the AKS nodes subnet | `string` | `"10.0.0.0/22"` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | CIDR of Virtual Network (used when provision\_vnet = true) | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vnet_dns_servers"></a> [vnet\_dns\_servers](#input\_vnet\_dns\_servers) | Custom DNS servers for the VNet. Leave empty for Azure default. | `list` | `[]` | no |
| <a name="input_workload_private_dns_zones"></a> [workload\_private\_dns\_zones](#input\_workload\_private\_dns\_zones) | List of private DNS zone names to create for workloads (e.g. app.internal, services.internal) | `list` | `[]` | no |
| <a name="input_workload_public_dns_zones"></a> [workload\_public\_dns\_zones](#input\_workload\_public\_dns\_zones) | List of public DNS zone names to create for workloads (e.g. contoso.com, contoso.io) | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_cluster_fqdn"></a> [aks\_cluster\_fqdn](#output\_aks\_cluster\_fqdn) | The private FQDN of the AKS cluster |
| <a name="output_aks_cluster_id"></a> [aks\_cluster\_id](#output\_aks\_cluster\_id) | The resource ID of the AKS cluster |
| <a name="output_aks_cluster_name"></a> [aks\_cluster\_name](#output\_aks\_cluster\_name) | The name of the AKS cluster |
| <a name="output_aks_controlplane_identity_client_id"></a> [aks\_controlplane\_identity\_client\_id](#output\_aks\_controlplane\_identity\_client\_id) | Client ID of the control plane managed identity |
| <a name="output_aks_controlplane_identity_id"></a> [aks\_controlplane\_identity\_id](#output\_aks\_controlplane\_identity\_id) | Resource ID of the control plane managed identity |
| <a name="output_aks_kubelet_identity_client_id"></a> [aks\_kubelet\_identity\_client\_id](#output\_aks\_kubelet\_identity\_client\_id) | Client ID of the kubelet managed identity |
| <a name="output_aks_oidc_issuer_url"></a> [aks\_oidc\_issuer\_url](#output\_aks\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster |
| <a name="output_aks_private_dns_zone_id"></a> [aks\_private\_dns\_zone\_id](#output\_aks\_private\_dns\_zone\_id) | Resource ID of the AKS control plane private DNS zone |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource ID of the AKS resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the AKS resource group |
| <a name="output_subnet_aks_apiserver_id"></a> [subnet\_aks\_apiserver\_id](#output\_subnet\_aks\_apiserver\_id) | Resource ID of the AKS API server subnet |
| <a name="output_subnet_aks_nodes_id"></a> [subnet\_aks\_nodes\_id](#output\_subnet\_aks\_nodes\_id) | Resource ID of the AKS nodes subnet |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Resource ID of the VNet |
| <a name="output_workload_dns_identity_client_id"></a> [workload\_dns\_identity\_client\_id](#output\_workload\_dns\_identity\_client\_id) | Client ID of the external-dns workload identity |
| <a name="output_workload_eso_identity_client_id"></a> [workload\_eso\_identity\_client\_id](#output\_workload\_eso\_identity\_client\_id) | Client ID of the ESO workload identity |
| <a name="output_workload_private_dns_zone_ids"></a> [workload\_private\_dns\_zone\_ids](#output\_workload\_private\_dns\_zone\_ids) | Map of workload private DNS zone IDs |
| <a name="output_workload_public_dns_zone_ids"></a> [workload\_public\_dns\_zone\_ids](#output\_workload\_public\_dns\_zone\_ids) | Map of workload public DNS zone IDs |
<!-- END_TF_DOCS -->