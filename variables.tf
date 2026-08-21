#########################################################################
##                     General Configuration Variables                 ##
#########################################################################

variable "az_subscription_id" {
  description = "Azure subscription to deploy resources"
  default     = "f7f8b016-64ca-4d42-afad-de91b2eae685"
}

variable "region" {
  description = "Azure region to deploy to"
  default     = "swedencentral"
}

variable "environment" {
  description = "Environment in which the infrastructure is going to be deployed"
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project / client / product to be used in naming convention"
  default     = "contoso"
}

variable "region_short" {
  description = "Short region code used in resource names with character limits (e.g. sc for swedencentral, weu for westeurope)"
  default     = "sc"
}

#########################################################################
##                   Networking Variables                              ##
#########################################################################

variable "provision_vnet" {
  description = "Whether to create a new VNet via lz-vending. When false, subnets are created in existing VNet."
  default     = true
}

variable "vnet_cidr" {
  description = "CIDR of Virtual Network (used when provision_vnet = true)"
  default     = "10.0.0.0/16"
}

variable "vnet_dns_servers" {
  description = "Custom DNS servers for the VNet. Leave empty for Azure default."
  default     = []
}

variable "subnet_aks_nodes_cidr" {
  description = "CIDR for the AKS nodes subnet"
  default     = "10.0.0.0/22"
}

variable "subnet_aks_apiserver_cidr" {
  description = "CIDR for the AKS API server subnet - minimum /28"
  default     = "10.0.4.0/28"
}

#########################################################################
##                   DNS Variables                                     ##
#########################################################################

variable "provision_controlplane_dns" {
  description = "Whether to create the control plane private DNS zone. When false, existing zone is looked up via data."
  default     = false
}

variable "workload_private_dns_zones" {
  description = "List of private DNS zone names to create for workloads (e.g. app.internal, services.internal)"
  default     = []
}

variable "workload_public_dns_zones" {
  description = "List of public DNS zone names to create for workloads (e.g. contoso.com, contoso.io)"
  default     = []
}

#########################################################################
##                   AKS Variables                                     ##
#########################################################################

variable "provision_aks" {
  description = "Whether to provision the AKS cluster"
  default     = true
}

variable "provision_kubelet_identity" {
  description = "Whether to create the kubelet identity. When false, an existing identity is looked up via data."
  default     = true
}

variable "provision_identities" {
  description = "Whether to create managed identities via lz-vending. When false, existing identities are looked up via data."
  default     = true
}

variable "aks_cluster_version" {
  description = "Desired Kubernetes cluster version"
  default     = "1.36"
}

variable "aks_private_cluster" {
  description = "Whether to make the AKS cluster private. When false, the API server is publicly accessible."
  default     = true
}

variable "aks_admin_group_ids" {
  description = "List of Azure AD group object IDs that will have admin role on the AKS cluster"
  default     = []
}

variable "aks_sku" {
  description = "The SKU of the AKS cluster. name: Base or Automatic. tier: Free, Standard, or Premium."
  default = {
    name = "Base"
    tier = "Free"
  }
}

variable "aks_outbound_type" {
  description = "The outbound (egress) routing method. Possible values: loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway."
  default     = "loadBalancer"
}

variable "aks_prometheus_workspace_id" {
  description = "Azure Monitor Workspace resource ID for managed Prometheus. Set to null to disable."
  default     = null
}

variable "aks_system_pool" {
  description = "Configuration for the default system node pool. The vnet_subnet_id is injected automatically."
  type = object({
    name                = string
    vm_size             = string
    os_sku              = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    count_of            = number
    os_disk_size_gb     = number
    upgrade_settings = object({
      max_surge = string
    })
  })
  default = {
    name                = "system"
    vm_size             = "Standard_B2ms"
    os_sku              = "AzureLinux"
    availability_zones  = ["1"]
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    count_of            = 1
    os_disk_size_gb     = 128
    upgrade_settings = {
      max_surge = "33%"
    }
  }
}

variable "aks_worker_pools" {
  description = "Map of additional worker node pools. The vnet_subnet_id is injected automatically. Leave empty for no worker pools."
  type = map(object({
    name                = string
    vm_size             = string
    os_sku              = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    count_of            = number
    os_disk_size_gb     = number
    mode                = string
    upgrade_settings = object({
      max_surge = string
    })
  }))
  default = {}
}

variable "aks_maintenance_windows" {
  description = "Maintenance window configuration for AKS. Leave empty to disable scheduled maintenance."
  type = map(object({
    name = string
    maintenance_window = object({
      duration_hours = number
      start_time     = string
      utc_offset     = string
      schedule = object({
        weekly = optional(object({
          day_of_week    = string
          interval_weeks = number
        }))
        daily = optional(object({
          interval_days = number
        }))
      })
    })
  }))
  default = {}
}

#########################################################################
##                   PostgreSQL Variables                              ##
#########################################################################

variable "provision_postgresql" {
  description = "Whether to provision an Azure Database for PostgreSQL Flexible Server"
  default     = false
}

variable "postgresql_version" {
  description = "PostgreSQL major version (13, 14, 15, 16, 17)"
  default     = "16"
}

variable "postgresql_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)"
  default     = "B_Standard_B1ms"
}

variable "postgresql_storage_mb" {
  description = "Storage size in MB (32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 8388608, 16777216)"
  default     = 32768
}

variable "postgresql_storage_tier" {
  description = "Storage tier (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80)"
  default     = "P4"
}

variable "postgresql_private_networking" {
  description = "Whether to deploy PostgreSQL with private networking (delegated subnet + private DNS zone + private endpoint). When false, public access with firewall rules."
  default     = true
}

variable "postgresql_manage_dns" {
  description = "Whether Terraform creates the private DNS zone and A record. Set to false when a landing zone policy manages DNS."
  default     = true
}

variable "subnet_postgresql_cidr" {
  description = "CIDR for the PostgreSQL delegated subnet"
  default     = "10.0.5.0/24"
}

variable "postgresql_high_availability" {
  description = "Whether to enable zone-redundant high availability"
  default     = false
}

variable "postgresql_zone" {
  description = "Availability zone for the primary PostgreSQL server"
  default     = "1"
}

variable "postgresql_backup_retention_days" {
  description = "Backup retention period in days (7-35)"
  default     = 7
}

variable "postgresql_geo_redundant_backup" {
  description = "Whether geo-redundant backup is enabled"
  default     = false
}

variable "postgresql_databases" {
  description = "Map of databases to create on the server"
  default = {
    backstage = {
      name      = "backstage"
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }
}

variable "postgresql_firewall_rules" {
  description = "Map of firewall rules for public mode. Each rule needs name, start_ip_address and end_ip_address."
  default = {
    allow_azure_services = {
      name             = "AllowAzureServices"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }
}

#########################################################################
##                   CosmosDB Variables                                ##
#########################################################################

variable "provision_cosmosdb" {
  description = "Whether to provision an Azure CosmosDB account"
  default     = false
}

variable "cosmosdb_private_networking" {
  description = "Whether to deploy CosmosDB with private endpoint. When false, public access with IP filtering."
  default     = true
}

variable "cosmosdb_manage_dns" {
  description = "Whether Terraform creates the private DNS zone and A record. Set to false when a landing zone policy manages DNS."
  default     = true
}

variable "cosmosdb_subresource_name" {
  description = "The private endpoint subresource. Possible values: SQL, SqlDedicated, Cassandra, MongoDB, Gremlin, Table."
  default     = "SQL"
}

variable "cosmosdb_capabilities" {
  description = "Set of capabilities to enable on the CosmosDB account (e.g. EnableServerless, EnableCassandra, EnableMongo, EnableTable, EnableGremlin)"
  default     = []
}

variable "cosmosdb_consistency_policy" {
  description = "Consistency policy for the CosmosDB account"
  default = {
    consistency_level = "Session"
  }
}

variable "cosmosdb_backup" {
  description = "Backup configuration for the CosmosDB account"
  default = {
    type = "Continuous"
    tier = "Continuous30Days"
  }
}

variable "cosmosdb_geo_locations" {
  description = "Geo-replication locations. Defaults to the deployment region with no zone redundancy."
  default     = null
}

variable "cosmosdb_capacity" {
  description = "Throughput capacity limit configuration"
  default = {
    total_throughput_limit = -1
  }
}

variable "cosmosdb_sql_databases" {
  description = "Map of SQL databases and containers to create"
  default     = {}
}

variable "cosmosdb_mongo_databases" {
  description = "Map of MongoDB databases and collections to create"
  default     = {}
}

variable "cosmosdb_mongo_server_version" {
  description = "MongoDB server version (3.2, 3.6, 4.0, 4.2, 5.0, 6.0, 7.0)"
  default     = "4.2"
}

variable "cosmosdb_disable_local_auth" {
  description = "Disable local authentication, enforcing AAD-only access (SQL API only)"
  default     = true
}

variable "cosmosdb_free_tier" {
  description = "Whether to enable the free tier (one per subscription)"
  default     = false
}

variable "cosmosdb_automatic_failover" {
  description = "Whether automatic failover is enabled"
  default     = true
}

variable "cosmosdb_multi_region_write" {
  description = "Whether multi-region writes are enabled"
  default     = false
}

variable "cosmosdb_ip_range_filter" {
  description = "Set of IP addresses/CIDR ranges allowed when public access is enabled"
  default     = []
}

#########################################################################
##                   Identity / RBAC Variables                         ##
#########################################################################

variable "enable_eso" {
  description = "Whether to enable External Secrets Operator integration. When true, looks up existing Key Vault via data and assigns role."
  default     = true
}

variable "enable_loki" {
  description = "Whether to enable Loki integration. When true, creates workload identity and assigns Storage Blob Data Contributor role."
  default     = false
}

#########################################################################
##                   Budget Variables                                  ##
#########################################################################

variable "budget_enabled" {
  description = "Whether to create subscription budgets"
  default     = false
}

variable "budgets" {
  description = "Map of budget configurations. See lz-vending module docs for schema."
  default     = {}
}
