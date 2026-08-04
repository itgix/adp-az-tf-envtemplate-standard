#########################################################################
##  DNS Zones                                                          ##
##  - If provision_*_dns = true, zones are created in dns.tf (skipped) ##
##  - If provision_*_dns = false, look up existing zones via data      ##
#########################################################################

# --- Control plane DNS zone (for AKS private cluster) ---
data "azurerm_private_dns_zone" "aks" {
  count = var.provision_controlplane_dns ? 0 : 1

  name                = "${var.project_name}.privatelink.${var.region}.azmk8s.io"
  resource_group_name = "rg-network-${var.environment}-${var.region}"
}

# --- Workload DNS zone (for external-dns / app records) ---
data "azurerm_private_dns_zone" "workload" {
  count = var.provision_workload_dns ? 0 : 1

  name                = "${var.project_name}.internal"
  resource_group_name = "rg-network-${var.environment}-${var.region}"
}

#########################################################################
##  Existing VNet (when provision_vnet = false)                        ##
#########################################################################

data "azurerm_virtual_network" "vnet" {
  count = var.provision_vnet ? 0 : 1

  name                = "vnet-${var.environment}-${var.region}"
  resource_group_name = "rg-network-${var.environment}-${var.region}"
}
