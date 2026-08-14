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
##                   Identity / RBAC Variables                         ##
#########################################################################

variable "enable_eso" {
  description = "Whether to enable External Secrets Operator integration. When true, looks up existing Key Vault via data and assigns role."
  default     = true
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
