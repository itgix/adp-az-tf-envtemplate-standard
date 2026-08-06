#########################################################################
##  Control Plane DNS Zone - Created when provision_controlplane_dns   ##
#########################################################################

resource "azurerm_private_dns_zone" "aks" {
  count = var.provision_controlplane_dns ? 1 : 0

  name                = "${var.project_name}.privatelink.${var.region}.azmk8s.io"
  resource_group_name = local.resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  count = var.provision_controlplane_dns ? 1 : 0

  name                  = "link-aks-${var.environment}-${var.region}"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks[0].name
  virtual_network_id    = local.vnet_id

  depends_on = [azurerm_private_dns_zone.aks]
}

#########################################################################
##  Workload Private DNS Zones - Always created from list              ##
#########################################################################

resource "azurerm_private_dns_zone" "workload" {
  for_each = toset(var.workload_private_dns_zones)

  name                = each.value
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "workload" {
  for_each = toset(var.workload_private_dns_zones)

  name                  = "link-${replace(each.value, ".", "-")}-${var.environment}"
  resource_group_name   = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.workload[each.value].name
  virtual_network_id    = local.vnet_id
}

#########################################################################
##  Workload Public DNS Zones - Always created from list               ##
#########################################################################

resource "azurerm_dns_zone" "public" {
  for_each = toset(var.workload_public_dns_zones)

  name                = each.value
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}
