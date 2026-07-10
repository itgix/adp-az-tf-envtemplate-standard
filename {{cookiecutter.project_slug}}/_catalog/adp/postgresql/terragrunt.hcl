terraform {
    source = "git::https://github.com/Azure/terraform-azurerm-avm-res-dbforpostgresql-flexibleserver?ref=v0.2.3"
}

exclude {
  if                   = !local.feature_enabled
  actions              = ["all"]
  exclude_dependencies = false
}

locals {
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars          = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  location        = local.region_vars.locals.location
  location_short  = local.region_vars.locals.location_short
  subscription_id = local.subscription_vars.locals.subscription_id
  environment     = local.env_vars.locals.environment
  root_vars       = read_terragrunt_config("${get_repo_root()}/root.hcl")

  features        = try(local.env_vars.locals.features, {})
  feature_key     = replace(basename(get_original_terragrunt_dir()), "-", "_")
  feature_enabled = try(local.features[local.feature_key], false)

  cfg = try(yamldecode(file("${get_original_terragrunt_dir()}/values.yaml")), {})

  inherited_tags = try(local.env_vars.locals.tags, {})
  default_tags   = local.root_vars.locals.default_tags
  tags           = merge(local.default_tags, local.inherited_tags, try(local.cfg.tags, {}))
}

inputs = {
  name                = "psql-${local.cfg.postfix}-${local.environment}-${local.location_short}"
  resource_group_name = local.cfg.resource_group_name
  location            = local.location

  administrator_login    = try(local.cfg.administrator_login, "psqladmin")
  administrator_password = local.cfg.administrator_password

  sku_name       = try(local.cfg.sku_name, "B_Standard_B1ms")
  server_version = try(local.cfg.postgresql_version, "16")

  storage_mb                   = try(local.cfg.storage_mb, 32768)
  backup_retention_days        = try(local.cfg.backup_retention_days, 7)
  geo_redundant_backup_enabled = try(local.cfg.geo_redundant_backup_enabled, false)
  zone                         = try(tostring(local.cfg.zone), "1")

  databases = try(local.cfg.databases, {})

  high_availability = try(local.cfg.high_availability, null)

  firewall_rules = try(local.cfg.firewall_rules, {
    allow_azure_services = {
      name             = "allow-azure-services"
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  })

  tags = local.tags

  enable_telemetry = local.root_vars.locals.enable_telemetry
}