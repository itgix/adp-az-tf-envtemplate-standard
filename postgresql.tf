#########################################################################
##                     PostgreSQL Flexible Server                      ##
#########################################################################

module "postgresql" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "0.2.3"

  count = var.provision_postgresql ? 1 : 0

  name                = "psql-${var.project_name}-${var.environment}-${var.region}"
  resource_group_name = local.resource_group_name
  location            = var.region

  sku_name       = var.postgresql_sku_name
  server_version = var.postgresql_version

  #---------------------------------------------------------------------------
  # Storage
  #---------------------------------------------------------------------------
  storage_mb        = var.postgresql_storage_mb
  storage_tier      = var.postgresql_storage_tier
  auto_grow_enabled = true

  #---------------------------------------------------------------------------
  # Authentication
  #---------------------------------------------------------------------------
  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  #---------------------------------------------------------------------------
  # Networking
  #---------------------------------------------------------------------------
  delegated_subnet_id = var.postgresql_private_networking ? (
    var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_postgresql_name}" : azurerm_subnet.postgresql[0].id
  ) : null

  private_dns_zone_id = var.postgresql_private_networking && var.postgresql_manage_dns ? (
    azurerm_private_dns_zone.postgresql[0].id
  ) : null

  public_network_access_enabled = !var.postgresql_private_networking

  #---------------------------------------------------------------------------
  # Private Endpoint (no zone group — DNS handled by Terraform or policy)
  #---------------------------------------------------------------------------
  private_endpoints = var.postgresql_private_networking ? {
    primary = {
      name               = local.pe_postgresql_name
      subnet_resource_id = var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_aks_nodes_name}" : azurerm_subnet.aks_nodes[0].id
    }
  } : {}

  #---------------------------------------------------------------------------
  # High Availability
  #---------------------------------------------------------------------------
  high_availability = var.postgresql_high_availability ? {
    mode = "ZoneRedundant"
  } : null

  zone = var.postgresql_zone

  #---------------------------------------------------------------------------
  # Backup
  #---------------------------------------------------------------------------
  backup_retention_days        = var.postgresql_backup_retention_days
  geo_redundant_backup_enabled = var.postgresql_geo_redundant_backup

  #---------------------------------------------------------------------------
  # Databases
  #---------------------------------------------------------------------------
  databases = var.postgresql_databases

  #---------------------------------------------------------------------------
  # Firewall Rules (public mode only)
  #---------------------------------------------------------------------------
  firewall_rules = !var.postgresql_private_networking ? var.postgresql_firewall_rules : {}

  #---------------------------------------------------------------------------
  # Tags
  #---------------------------------------------------------------------------
  tags = local.common_tags

  enable_telemetry = false

  depends_on = [
    module.lz_vending,
    azurerm_private_dns_zone_virtual_network_link.postgresql,
  ]
}

#########################################################################
##  PostgreSQL Delegated Subnet (existing VNet, provision_vnet = false) ##
#########################################################################

resource "azurerm_subnet" "postgresql" {
  count = !var.provision_vnet && var.provision_postgresql && var.postgresql_private_networking ? 1 : 0

  name                 = local.subnet_postgresql_name
  resource_group_name  = data.azurerm_virtual_network.vnet[0].resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.subnet_postgresql_cidr]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

#########################################################################
##  PostgreSQL Private DNS Zone + VNet Link + A Record                 ##
##  Only when NOT landing zone (dns_zone_group = true)                 ##
#########################################################################

resource "azurerm_private_dns_zone" "postgresql" {
  count = var.provision_postgresql && var.postgresql_private_networking && var.postgresql_manage_dns ? 1 : 0

  name                = "${var.project_name}.postgres.database.azure.com"
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  tags                = local.common_tags

  depends_on = [module.lz_vending]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  count = var.provision_postgresql && var.postgresql_private_networking && var.postgresql_manage_dns ? 1 : 0

  name                  = "link-psql-${var.environment}-${var.region}"
  resource_group_name   = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql[0].name
  virtual_network_id    = local.vnet_id
}

resource "azurerm_private_dns_a_record" "postgresql" {
  count = var.provision_postgresql && var.postgresql_private_networking && var.postgresql_manage_dns ? 1 : 0

  name                = "psql-${var.project_name}-${var.environment}-${var.region}"
  zone_name           = azurerm_private_dns_zone.postgresql[0].name
  resource_group_name = var.provision_vnet ? local.resource_group_name : local.network_resource_group_name
  ttl                 = 300
  records             = [module.postgresql[0].private_endpoints[local.pe_postgresql_name].private_service_connection[0].private_ip_address]
}
