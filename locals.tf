locals {
  resource_group_name          = "rg-aks-${var.environment}-${var.region}"
  network_resource_group_name  = "rg-network-${var.environment}-${var.region}"
  managed_resource_group_name  = "rg-managed-${var.environment}-${var.region}"
  aks_node_resource_group_name = "rg-aks-nodes-${var.environment}-${var.region}"

  # Control plane DNS zone ID
  aks_private_dns_zone_id = var.provision_controlplane_dns ? azurerm_private_dns_zone.aks[0].id : data.azurerm_private_dns_zone.aks[0].id

  # VNet ID
  vnet_id = var.provision_vnet ? module.lz_vending.virtual_network_resource_ids["aks"] : data.azurerm_virtual_network.vnet[0].id

  # Subnet names
  subnet_aks_nodes_name     = "snet-aks-nodes-${var.environment}-${var.region}"
  subnet_aks_apiserver_name = "snet-aks-apiserver-${var.environment}-${var.region}"

  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}
