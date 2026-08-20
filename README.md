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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/avm-res-containerservice-managedcluster/azurerm | 0.8.1 |
| <a name="module_cosmosdb"></a> [cosmosdb](#module\_cosmosdb) | Azure/avm-res-documentdb-databaseaccount/azurerm | 0.10.0 |
| <a name="module_lz_vending"></a> [lz\_vending](#module\_lz\_vending) | Azure/avm-ptn-alz-sub-vending/azure | 0.3.0 |
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql) | Azure/avm-res-dbforpostgresql-flexibleserver/azurerm | 0.2.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_federated_identity_credential.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.external_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_federated_identity_credential.loki](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_private_dns_a_record.cosmosdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.cosmosdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.workload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.cosmosdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.workload](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_subnet.aks_apiserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.aks_nodes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.eso](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_private_dns_zone.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_private_endpoint_connection.cosmosdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_endpoint_connection) | data source |
| [azurerm_private_endpoint_connection.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_endpoint_connection) | data source |
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
| <a name="input_cosmosdb_automatic_failover"></a> [cosmosdb\_automatic\_failover](#input\_cosmosdb\_automatic\_failover) | Whether automatic failover is enabled | `bool` | `true` | no |
| <a name="input_cosmosdb_backup"></a> [cosmosdb\_backup](#input\_cosmosdb\_backup) | Backup configuration for the CosmosDB account | `map` | <pre>{<br/>  "tier": "Continuous30Days",<br/>  "type": "Continuous"<br/>}</pre> | no |
| <a name="input_cosmosdb_capabilities"></a> [cosmosdb\_capabilities](#input\_cosmosdb\_capabilities) | Set of capabilities to enable on the CosmosDB account (e.g. EnableServerless, EnableCassandra, EnableMongo, EnableTable, EnableGremlin) | `list` | `[]` | no |
| <a name="input_cosmosdb_capacity"></a> [cosmosdb\_capacity](#input\_cosmosdb\_capacity) | Throughput capacity limit configuration | `map` | <pre>{<br/>  "total_throughput_limit": -1<br/>}</pre> | no |
| <a name="input_cosmosdb_consistency_policy"></a> [cosmosdb\_consistency\_policy](#input\_cosmosdb\_consistency\_policy) | Consistency policy for the CosmosDB account | `map` | <pre>{<br/>  "consistency_level": "Session"<br/>}</pre> | no |
| <a name="input_cosmosdb_disable_local_auth"></a> [cosmosdb\_disable\_local\_auth](#input\_cosmosdb\_disable\_local\_auth) | Disable local authentication, enforcing AAD-only access (SQL API only) | `bool` | `true` | no |
| <a name="input_cosmosdb_free_tier"></a> [cosmosdb\_free\_tier](#input\_cosmosdb\_free\_tier) | Whether to enable the free tier (one per subscription) | `bool` | `false` | no |
| <a name="input_cosmosdb_geo_locations"></a> [cosmosdb\_geo\_locations](#input\_cosmosdb\_geo\_locations) | Geo-replication locations. Defaults to the deployment region with no zone redundancy. | `any` | `null` | no |
| <a name="input_cosmosdb_ip_range_filter"></a> [cosmosdb\_ip\_range\_filter](#input\_cosmosdb\_ip\_range\_filter) | Set of IP addresses/CIDR ranges allowed when public access is enabled | `list` | `[]` | no |
| <a name="input_cosmosdb_manage_dns"></a> [cosmosdb\_manage\_dns](#input\_cosmosdb\_manage\_dns) | Whether Terraform creates the private DNS zone and A record. Set to false when a landing zone policy manages DNS. | `bool` | `true` | no |
| <a name="input_cosmosdb_mongo_databases"></a> [cosmosdb\_mongo\_databases](#input\_cosmosdb\_mongo\_databases) | Map of MongoDB databases and collections to create | `map` | `{}` | no |
| <a name="input_cosmosdb_mongo_server_version"></a> [cosmosdb\_mongo\_server\_version](#input\_cosmosdb\_mongo\_server\_version) | MongoDB server version (3.2, 3.6, 4.0, 4.2, 5.0, 6.0, 7.0) | `string` | `"4.2"` | no |
| <a name="input_cosmosdb_multi_region_write"></a> [cosmosdb\_multi\_region\_write](#input\_cosmosdb\_multi\_region\_write) | Whether multi-region writes are enabled | `bool` | `false` | no |
| <a name="input_cosmosdb_private_networking"></a> [cosmosdb\_private\_networking](#input\_cosmosdb\_private\_networking) | Whether to deploy CosmosDB with private endpoint. When false, public access with IP filtering. | `bool` | `true` | no |
| <a name="input_cosmosdb_sql_databases"></a> [cosmosdb\_sql\_databases](#input\_cosmosdb\_sql\_databases) | Map of SQL databases and containers to create | `map` | `{}` | no |
| <a name="input_cosmosdb_subresource_name"></a> [cosmosdb\_subresource\_name](#input\_cosmosdb\_subresource\_name) | The private endpoint subresource. Possible values: SQL, SqlDedicated, Cassandra, MongoDB, Gremlin, Table. | `string` | `"SQL"` | no |
| <a name="input_enable_eso"></a> [enable\_eso](#input\_enable\_eso) | Whether to enable External Secrets Operator integration. When true, looks up existing Key Vault via data and assigns role. | `bool` | `true` | no |
| <a name="input_enable_loki"></a> [enable\_loki](#input\_enable\_loki) | Whether to enable Loki integration. When true, creates workload identity and assigns Storage Blob Data Contributor role. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the infrastructure is going to be deployed | `string` | `"dev"` | no |
| <a name="input_postgresql_backup_retention_days"></a> [postgresql\_backup\_retention\_days](#input\_postgresql\_backup\_retention\_days) | Backup retention period in days (7-35) | `number` | `7` | no |
| <a name="input_postgresql_databases"></a> [postgresql\_databases](#input\_postgresql\_databases) | Map of databases to create on the server | `map` | <pre>{<br/>  "backstage": {<br/>    "charset": "UTF8",<br/>    "collation": "en_US.utf8",<br/>    "name": "backstage"<br/>  }<br/>}</pre> | no |
| <a name="input_postgresql_firewall_rules"></a> [postgresql\_firewall\_rules](#input\_postgresql\_firewall\_rules) | Map of firewall rules for public mode. Each rule needs name, start\_ip\_address and end\_ip\_address. | `map` | <pre>{<br/>  "allow_azure_services": {<br/>    "end_ip_address": "0.0.0.0",<br/>    "name": "AllowAzureServices",<br/>    "start_ip_address": "0.0.0.0"<br/>  }<br/>}</pre> | no |
| <a name="input_postgresql_geo_redundant_backup"></a> [postgresql\_geo\_redundant\_backup](#input\_postgresql\_geo\_redundant\_backup) | Whether geo-redundant backup is enabled | `bool` | `false` | no |
| <a name="input_postgresql_high_availability"></a> [postgresql\_high\_availability](#input\_postgresql\_high\_availability) | Whether to enable zone-redundant high availability | `bool` | `false` | no |
| <a name="input_postgresql_manage_dns"></a> [postgresql\_manage\_dns](#input\_postgresql\_manage\_dns) | Whether Terraform creates the private DNS zone and A record. Set to false when a landing zone policy manages DNS. | `bool` | `true` | no |
| <a name="input_postgresql_private_networking"></a> [postgresql\_private\_networking](#input\_postgresql\_private\_networking) | Whether to deploy PostgreSQL with private networking (delegated subnet + private DNS zone + private endpoint). When false, public access with firewall rules. | `bool` | `true` | no |
| <a name="input_postgresql_sku_name"></a> [postgresql\_sku\_name](#input\_postgresql\_sku\_name) | The SKU name for the PostgreSQL Flexible Server (e.g. B\_Standard\_B1ms, GP\_Standard\_D2s\_v3, MO\_Standard\_E4s\_v3) | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_postgresql_storage_mb"></a> [postgresql\_storage\_mb](#input\_postgresql\_storage\_mb) | Storage size in MB (32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 8388608, 16777216) | `number` | `32768` | no |
| <a name="input_postgresql_storage_tier"></a> [postgresql\_storage\_tier](#input\_postgresql\_storage\_tier) | Storage tier (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80) | `string` | `"P4"` | no |
| <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version) | PostgreSQL major version (13, 14, 15, 16, 17) | `string` | `"16"` | no |
| <a name="input_postgresql_zone"></a> [postgresql\_zone](#input\_postgresql\_zone) | Availability zone for the primary PostgreSQL server | `string` | `"1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project / client / product to be used in naming convention | `string` | `"contoso"` | no |
| <a name="input_provision_aks"></a> [provision\_aks](#input\_provision\_aks) | Whether to provision the AKS cluster | `bool` | `true` | no |
| <a name="input_provision_controlplane_dns"></a> [provision\_controlplane\_dns](#input\_provision\_controlplane\_dns) | Whether to create the control plane private DNS zone. When false, existing zone is looked up via data. | `bool` | `false` | no |
| <a name="input_provision_cosmosdb"></a> [provision\_cosmosdb](#input\_provision\_cosmosdb) | Whether to provision an Azure CosmosDB account | `bool` | `false` | no |
| <a name="input_provision_identities"></a> [provision\_identities](#input\_provision\_identities) | Whether to create managed identities via lz-vending. When false, existing identities are looked up via data. | `bool` | `true` | no |
| <a name="input_provision_kubelet_identity"></a> [provision\_kubelet\_identity](#input\_provision\_kubelet\_identity) | Whether to create the kubelet identity. When false, an existing identity is looked up via data. | `bool` | `true` | no |
| <a name="input_provision_postgresql"></a> [provision\_postgresql](#input\_provision\_postgresql) | Whether to provision an Azure Database for PostgreSQL Flexible Server | `bool` | `false` | no |
| <a name="input_provision_vnet"></a> [provision\_vnet](#input\_provision\_vnet) | Whether to create a new VNet via lz-vending. When false, subnets are created in existing VNet. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region to deploy to | `string` | `"swedencentral"` | no |
| <a name="input_region_short"></a> [region\_short](#input\_region\_short) | Short region code used in resource names with character limits (e.g. sc for swedencentral, weu for westeurope) | `string` | `"sc"` | no |
| <a name="input_subnet_aks_apiserver_cidr"></a> [subnet\_aks\_apiserver\_cidr](#input\_subnet\_aks\_apiserver\_cidr) | CIDR for the AKS API server subnet - minimum /28 | `string` | `"10.0.4.0/28"` | no |
| <a name="input_subnet_aks_nodes_cidr"></a> [subnet\_aks\_nodes\_cidr](#input\_subnet\_aks\_nodes\_cidr) | CIDR for the AKS nodes subnet | `string` | `"10.0.0.0/22"` | no |
| <a name="input_subnet_postgresql_cidr"></a> [subnet\_postgresql\_cidr](#input\_subnet\_postgresql\_cidr) | CIDR for the PostgreSQL delegated subnet | `string` | `"10.0.5.0/24"` | no |
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
| <a name="output_cosmosdb_account_id"></a> [cosmosdb\_account\_id](#output\_cosmosdb\_account\_id) | Resource ID of the CosmosDB account |
| <a name="output_cosmosdb_account_name"></a> [cosmosdb\_account\_name](#output\_cosmosdb\_account\_name) | Name of the CosmosDB account |
| <a name="output_cosmosdb_endpoint"></a> [cosmosdb\_endpoint](#output\_cosmosdb\_endpoint) | Endpoint of the CosmosDB account |
| <a name="output_postgresql_server_fqdn"></a> [postgresql\_server\_fqdn](#output\_postgresql\_server\_fqdn) | FQDN of the PostgreSQL Flexible Server |
| <a name="output_postgresql_server_id"></a> [postgresql\_server\_id](#output\_postgresql\_server\_id) | Resource ID of the PostgreSQL Flexible Server |
| <a name="output_postgresql_server_name"></a> [postgresql\_server\_name](#output\_postgresql\_server\_name) | Name of the PostgreSQL Flexible Server |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource ID of the AKS resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the AKS resource group |
| <a name="output_subnet_aks_apiserver_id"></a> [subnet\_aks\_apiserver\_id](#output\_subnet\_aks\_apiserver\_id) | Resource ID of the AKS API server subnet |
| <a name="output_subnet_aks_nodes_id"></a> [subnet\_aks\_nodes\_id](#output\_subnet\_aks\_nodes\_id) | Resource ID of the AKS nodes subnet |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Resource ID of the VNet |
| <a name="output_workload_dns_identity_client_id"></a> [workload\_dns\_identity\_client\_id](#output\_workload\_dns\_identity\_client\_id) | Client ID of the external-dns workload identity |
| <a name="output_workload_eso_identity_client_id"></a> [workload\_eso\_identity\_client\_id](#output\_workload\_eso\_identity\_client\_id) | Client ID of the ESO workload identity |
| <a name="output_workload_loki_identity_client_id"></a> [workload\_loki\_identity\_client\_id](#output\_workload\_loki\_identity\_client\_id) | Client ID of the Loki workload identity |
| <a name="output_workload_private_dns_zone_ids"></a> [workload\_private\_dns\_zone\_ids](#output\_workload\_private\_dns\_zone\_ids) | Map of workload private DNS zone IDs |
| <a name="output_workload_public_dns_zone_ids"></a> [workload\_public\_dns\_zone\_ids](#output\_workload\_public\_dns\_zone\_ids) | Map of workload public DNS zone IDs |
<!-- END_TF_DOCS -->