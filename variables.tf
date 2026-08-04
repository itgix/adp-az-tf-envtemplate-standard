#########################################################################
##                     General Configuration Variables                 ##
#########################################################################

variable "az_subscription_id" {
  type        = string
  description = "Azure subscription to deploy resources"
  default     = "f7f8b016-64ca-4d42-afad-de91b2eae685"
}

variable "region" {
  type        = string
  description = "Azure region to deploy to"
  default     = "swedencentral"
}

variable "environment" {
  type        = string
  description = "Environment in which the infrastructure is going to be deployed"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Name of the project / client / product to be used in naming convention"
  default     = "contoso"
}

#########################################################################
##                   Networking Variables                              ##
#########################################################################

variable "provision_vnet" {
  type        = bool
  description = "Whether to create a new VNet via lz-vending. When false, subnet IDs must be provided."
  default     = true
}

# --- Variables for provision_vnet = true ---

variable "vnet_cidr" {
  type        = string
  description = "CIDR of Virtual Network (used when provision_vnet = true)"
  default     = "10.0.0.0/16"
}

variable "vnet_dns_servers" {
  type        = list(string)
  description = "Custom DNS servers for the VNet. Leave empty for Azure default."
  default     = []
}

variable "subnet_aks_nodes_name" {
  type        = string
  description = "Name of the AKS nodes subnet"
  default     = "snet-aks-nodes"
}

variable "subnet_aks_nodes_cidr" {
  type        = string
  description = "CIDR for the AKS nodes subnet (used when provision_vnet = true)"
  default     = "10.0.0.0/22"
}

variable "subnet_aks_apiserver_name" {
  type        = string
  description = "Name of the AKS API server subnet"
  default     = "snet-aks-apiserver"
}

variable "subnet_aks_apiserver_cidr" {
  type        = string
  description = "CIDR for the AKS API server subnet - minimum /28 (used when provision_vnet = true)"
  default     = "10.0.4.0/28"
}

# --- AKS control plane private DNS zone ---

variable "provision_controlplane_dns" {
  type        = bool
  description = "Whether to create the control plane private DNS zone. When false, an existing zone is looked up via data."
  default     = false
}

# --- Workload private DNS zone (external-dns / app records) ---

variable "provision_workload_dns" {
  type        = bool
  description = "Whether to create the workload private DNS zone. When false, an existing zone is looked up via data."
  default     = false
}

# --- Public DNS zone (for external-facing records) ---

variable "provision_public_dns" {
  type        = bool
  description = "Whether to create the public DNS zone. When false, an existing zone is looked up via data."
  default     = false
}

#########################################################################
##                   AKS Variables                                     ##
#########################################################################

variable "provision_aks" {
  type        = bool
  description = "Whether to provision the AKS cluster"
  default     = true
}

variable "aks_cluster_version" {
  type        = string
  description = "Desired Kubernetes cluster version"
  default     = "1.36"
}

variable "aks_admin_group_ids" {
  type        = list(string)
  description = "List of Azure AD group object IDs that will have admin role on the AKS cluster"
  default     = []
}

variable "aks_kubelet_identity_id" {
  type        = string
  description = "Resource ID of an existing user-assigned managed identity for the kubelet. Leave empty to use the one created by lz-vending."
  default     = ""
}

variable "aks_prometheus_workspace_id" {
  type        = string
  description = "Azure Monitor Workspace resource ID for managed Prometheus. Set to null to disable."
  default     = null
}

variable "aks_system_pool" {
  type        = any
  description = "Configuration for the default system node pool. The vnet_subnet_id is injected automatically."
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
  type        = any
  description = "Map of additional worker node pools. The vnet_subnet_id is injected automatically. Leave empty for no worker pools."
  default     = {}
}

#########################################################################
##                   Identity / RBAC Variables                         ##
#########################################################################

variable "key_vault_resource_id" {
  type        = string
  description = "Resource ID of the Key Vault for ESO workload identity role assignment"
  default     = ""
}

#########################################################################
##                   Budget Variables                                  ##
#########################################################################

variable "budget_enabled" {
  type        = bool
  description = "Whether to create subscription budgets"
  default     = false
}

variable "budgets" {
  type        = any
  description = "Map of budget configurations. See lz-vending module docs for schema."
  default     = {}
}
