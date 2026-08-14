#########################################################################
##  Subnets - Created in existing VNet when provision_vnet = false     ##
#########################################################################

resource "azurerm_subnet" "aks_nodes" {
  count                = var.provision_vnet ? 0 : 1

  name                 = local.subnet_aks_nodes_name
  resource_group_name  = data.azurerm_virtual_network.vnet[0].resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.subnet_aks_nodes_cidr]
}

resource "azurerm_subnet" "aks_apiserver" {
  count                = var.provision_vnet ? 0 : 1
  
  name                 = local.subnet_aks_apiserver_name
  resource_group_name  = data.azurerm_virtual_network.vnet[0].resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.subnet_aks_apiserver_cidr]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
