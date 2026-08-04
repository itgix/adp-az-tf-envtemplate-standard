#########################################################################
##  Private DNS Zones - Created when provision_*_dns = true           ##
#########################################################################

resource "azurerm_private_dns_zone" "aks" {
  count               = var.provision_controlplane_dns ? 1 : 0

  name                = "${var.project_name}.privatelink.${var.region}.azmk8s.io"
  resource_group_name = local.resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  count                 = var.provision_controlplane_dns ? 1 : 0

  name                  = "link-aks-${var.environment}-${var.region}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks[0].name
  virtual_network_id    = var.provision_vnet ? module.lz_vending.virtual_network_resource_ids["aks"] : data.azurerm_virtual_network.vnet[0].id

  depends_on = [azurerm_private_dns_zone.aks]
}

resource "azurerm_private_dns_zone" "workload" {
  count = var.provision_workload_dns ? 1 : 0

  name                = "${var.project_name}.internal"
  resource_group_name = local.resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "workload" {
  count = var.provision_workload_dns ? 1 : 0

  name                  = "link-workload-${var.environment}-${var.region}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.workload[0].name
  virtual_network_id    = var.provision_vnet ? module.lz_vending.virtual_network_resource_ids["aks"] : data.azurerm_virtual_network.vnet[0].id

  depends_on = [azurerm_private_dns_zone.workload]
}

#########################################################################
##  Public DNS Zone - Created when provision_public_dns = true         ##
#########################################################################

resource "azurerm_dns_zone" "public" {
  count               = var.provision_public_dns ? 1 : 0
  
  name                = "${var.project_name}.com"
  resource_group_name = local.resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}
