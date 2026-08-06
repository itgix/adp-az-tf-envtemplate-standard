#########################################################################
##  Control Plane DNS Zone (provided by landing zone)                  ##
#########################################################################

data "azurerm_private_dns_zone" "aks" {
  count = var.provision_controlplane_dns ? 0 : 1

  name                = "${var.project_name}.privatelink.${var.region}.azmk8s.io"
  resource_group_name = local.network_resource_group_name
}

#########################################################################
##  Existing VNet (when provision_vnet = false)                        ##
#########################################################################

data "azurerm_virtual_network" "vnet" {
  count = var.provision_vnet ? 0 : 1

  name                = "vnet-${var.environment}-${var.region}"
  resource_group_name = local.network_resource_group_name
}

#########################################################################
##  Existing Kubelet Identity (when not created by lz-vending)         ##
#########################################################################

data "azurerm_user_assigned_identity" "kubelet" {
  count = var.provision_kubelet_identity ? 0 : 1

  name                = "id-aks-kubelet-${var.environment}-${var.region}"
  resource_group_name = local.resource_group_name
}

#########################################################################
##  Existing Key Vault (when enable_eso = true)                        ##
#########################################################################

data "azurerm_key_vault" "eso" {
  count = var.enable_eso ? 1 : 0

  name                = "kv-${var.project_name}-${var.environment}-${var.region_short}"
  resource_group_name = local.managed_resource_group_name
}
