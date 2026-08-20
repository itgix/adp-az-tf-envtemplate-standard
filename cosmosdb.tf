#########################################################################
##                     CosmosDB Account                                ##
#########################################################################

module "cosmosdb" {
  source  = "Azure/avm-res-documentdb-databaseaccount/azurerm"
  version = "0.10.0"

  count = var.provision_cosmosdb ? 1 : 0

  name                = "cosmos-${var.project_name}-${var.environment}-${var.region}"
  resource_group_name = local.resource_group_name
  location            = var.region

  #---------------------------------------------------------------------------
  # API / Capabilities
  #---------------------------------------------------------------------------
  capabilities = var.cosmosdb_capabilities

  #---------------------------------------------------------------------------
  # Consistency
  #---------------------------------------------------------------------------
  consistency_policy = var.cosmosdb_consistency_policy

  #---------------------------------------------------------------------------
  # Backup
  #---------------------------------------------------------------------------
  backup = var.cosmosdb_backup

  #---------------------------------------------------------------------------
  # Geo-replication
  #---------------------------------------------------------------------------
  geo_locations = var.cosmosdb_geo_locations != null ? var.cosmosdb_geo_locations : [
    {
      location          = var.region
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  #---------------------------------------------------------------------------
  # Networking
  #---------------------------------------------------------------------------
  public_network_access_enabled = !var.cosmosdb_private_networking

  #---------------------------------------------------------------------------
  # Private Endpoint (no dns_zone_group — DNS managed by Terraform or policy)
  #---------------------------------------------------------------------------
  private_endpoints_manage_dns_zone_group = false

  private_endpoints = var.cosmosdb_private_networking ? {
    primary = {
      name               = local.pe_cosmosdb_name
      subnet_resource_id = var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_aks_nodes_name}" : azurerm_subnet.aks_nodes[0].id
      subresource_name   = var.cosmosdb_subresource_name
    }
  } : {}

  #---------------------------------------------------------------------------
  # Firewall (public mode)
  #---------------------------------------------------------------------------
  ip_range_filter = !var.cosmosdb_private_networking ? var.cosmosdb_ip_range_filter : []

  #---------------------------------------------------------------------------
  # Capacity
  #---------------------------------------------------------------------------
  capacity = var.cosmosdb_capacity

  #---------------------------------------------------------------------------
  # SQL Databases
  #---------------------------------------------------------------------------
  sql_databases = var.cosmosdb_sql_databases

  #---------------------------------------------------------------------------
  # Mongo Databases
  #---------------------------------------------------------------------------
  mongo_databases      = var.cosmosdb_mongo_databases
  mongo_server_version = var.cosmosdb_mongo_server_version

  #---------------------------------------------------------------------------
  # Auth
  #---------------------------------------------------------------------------
  local_authentication_disabled = var.cosmosdb_disable_local_auth

  #---------------------------------------------------------------------------
  # Other
  #---------------------------------------------------------------------------
  free_tier_enabled               = var.cosmosdb_free_tier
  automatic_failover_enabled      = var.cosmosdb_automatic_failover
  multiple_write_locations_enabled = var.cosmosdb_multi_region_write

  #---------------------------------------------------------------------------
  # Tags
  #---------------------------------------------------------------------------
  tags = local.common_tags

  enable_telemetry = false

  depends_on = [module.lz_vending]
}

#########################################################################
##  CosmosDB Private DNS Zone + VNet Link + A Record                  ##
##  Only when Terraform manages DNS (cosmosdb_manage_dns = true)       ##
#########################################################################

resource "azurerm_private_dns_zone" "cosmosdb" {
  count = var.provision_cosmosdb && var.cosmosdb_private_networking && var.cosmosdb_manage_dns ? 1 : 0

  name                = "privatelink.documents.azure.com"
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmosdb" {
  count = var.provision_cosmosdb && var.cosmosdb_private_networking && var.cosmosdb_manage_dns ? 1 : 0

  name                  = "link-cosmos-${var.environment}-${var.region}"
  resource_group_name   = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmosdb[0].name
  virtual_network_id    = local.vnet_id
}

data "azurerm_private_endpoint_connection" "cosmosdb" {
  count = var.provision_cosmosdb && var.cosmosdb_private_networking && var.cosmosdb_manage_dns ? 1 : 0

  name                = local.pe_cosmosdb_name
  resource_group_name = local.resource_group_name

  depends_on = [module.cosmosdb]
}

resource "azurerm_private_dns_a_record" "cosmosdb" {
  count = var.provision_cosmosdb && var.cosmosdb_private_networking && var.cosmosdb_manage_dns ? 1 : 0

  name                = "cosmos-${var.project_name}-${var.environment}-${var.region}"
  zone_name           = azurerm_private_dns_zone.cosmosdb[0].name
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.cosmosdb[0].private_service_connection[0].private_ip_address]
}
