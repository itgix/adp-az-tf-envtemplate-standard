# =============================================================================
# Catalog: adp/lz-vending
# Consolidated landing zone vending module that provisions:
#   - Resource groups
#   - Virtual networks + NSGs
#   - User-assigned managed identities (AKS + workload identities)
# Environment-specific values come from values.yaml in each leaf folder.
# =============================================================================

terraform {
  source = "git::https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending?ref=v0.3.0"
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
  root_vars         = read_terragrunt_config("${get_repo_root()}/root.hcl")

  location        = local.region_vars.locals.location
  subscription_id = local.subscription_vars.locals.subscription_id
  environment     = local.env_vars.locals.environment

  features        = try(local.env_vars.locals.features, {})
  feature_key     = replace(basename(get_original_terragrunt_dir()), "-", "_")
  feature_enabled = try(local.features[local.feature_key], false)

  cfg = try(yamldecode(file("${get_original_terragrunt_dir()}/values.yaml")), {})

  inherited_tags = try(local.env_vars.locals.tags, {})
  default_tags   = local.root_vars.locals.default_tags
  tags           = merge(local.default_tags, local.inherited_tags, try(local.cfg.tags, {}))
}

generate "aks_subnet" {
  path      = "aks_subnet.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
variable "create_subnet" {
  type    = bool
  default = false
}

variable "subnet_name" {
  type    = string
  default = ""
}

variable "subnet_address_prefixes" {
  type    = list(string)
  default = []
}

variable "subnet_vnet_resource_id" {
  type    = string
  default = ""
}

variable "aks_subnet_name" {
  type    = string
  default = ""
}

resource "azurerm_subnet" "aks" {
  count                = var.create_subnet ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = split("/", var.subnet_vnet_resource_id)[4]
  virtual_network_name = split("/", var.subnet_vnet_resource_id)[8]
  address_prefixes     = var.subnet_address_prefixes
}

output "aks_subnet_id" {
  value = var.create_subnet ? azurerm_subnet.aks[0].id : try("$${values(module.virtualnetwork)[0].resource_id}/subnets/$${var.aks_subnet_name}", "")
}
EOF
}

inputs = {
  location        = local.location
  subscription_id = local.subscription_id

  subscription_enabled                              = false
  subscription_management_group_association_enabled = false
  budget_enabled                                    = false
  role_assignment_enabled                           = true
  disable_telemetry                                 = !local.root_vars.locals.enable_telemetry

  role_assignments = {
    for k, v in try(local.cfg.role_assignments, {}) :
    k => {
      principal_id         = v.principal_id
      role_definition_name = v.role_definition_name
      scope                = v.scope
    }
  }

  # --- Resource Groups ---
  resource_group_creation_enabled = true
  resource_groups = {
    aks = {
      name     = try(local.cfg.resource_group_name, "rg-aks-${local.environment}-${local.location}")
      location = local.location
      tags     = local.tags
    }
  }

  # --- Virtual Network + Subnets ---
  virtual_network_enabled = try(local.cfg.vnet_enabled, true)
  virtual_networks = try(local.cfg.vnet_enabled, true) ? {
    vnet = {
      name               = try(local.cfg.vnet.name, "vnet-aks-${local.environment}-${local.location}")
      address_space      = try(local.cfg.vnet.address_space, [])
      location           = local.location
      resource_group_key = "aks"
      tags               = merge(local.tags, try(local.cfg.vnet.tags, {}))

      subnets = {
        for s in try(local.cfg.vnet.subnets, []) :
        s.key => {
          name             = s.name
          address_prefixes = s.cidrs

          network_security_group = {
            key_reference = "nsg-${s.key}"
          }
        }
      }
    }
  } : {}

  # --- Network Security Groups ---
  network_security_group_enabled = try(local.cfg.vnet_enabled, true)
  network_security_groups = try(local.cfg.vnet_enabled, true) ? {
    for s in try(local.cfg.vnet.subnets, []) :
    "nsg-${s.key}" => {
      name               = "nsg-${s.name}-${local.environment}-${local.location}"
      resource_group_key = "aks"
      location           = local.location
      tags               = local.tags

      security_rules = merge(
        {
          allow-vnet-https-inbound = {
            name                       = "allow-vnet-https-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefix      = "VirtualNetwork"
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_range     = "443"
          }
          allow-lb-probes = {
            name                       = "allow-lb-probes"
            priority                   = 200
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "*"
            source_address_prefix      = "AzureLoadBalancer"
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_range     = "*"
          }
          allow-vnet-outbound = {
            name                       = "allow-vnet-outbound"
            priority                   = 100
            direction                  = "Outbound"
            access                     = "Allow"
            protocol                   = "*"
            source_address_prefix      = "VirtualNetwork"
            source_port_range          = "*"
            destination_address_prefix = "VirtualNetwork"
            destination_port_range     = "*"
          }
          allow-https-outbound = {
            name                       = "allow-https-outbound"
            priority                   = 200
            direction                  = "Outbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_address_prefix      = "*"
            source_port_range          = "*"
            destination_address_prefix = "*"
            destination_port_range     = "443"
          }
        },
        {
          for rule_key, rule in try(local.cfg.nsg_extra_rules[s.key], {}) :
          rule_key => merge(rule, { name = rule_key, source_port_range = try(rule.source_port_range, "*") })
        }
      )
    }
  } : {}

  # --- User-Assigned Managed Identities ---
  umi_enabled = true
  user_managed_identities = {
    for k, v in try(local.cfg.user_managed_identities, {}) :
    k => {
      name               = "${k}-${local.environment}-${local.location}"
      location           = local.location
      resource_group_key = "aks"
      tags               = merge(local.tags, try(v.tags, {}))
      role_assignments   = try(v.role_assignments, {})
      federated_credentials_advanced = {
        for cred_key, cred in try(v.federated_credentials_advanced, {}) :
        cred_key => {
          name               = "${k}-${local.environment}-${local.location}-${cred_key}"
          subject_identifier = cred.subject_identifier
          issuer_url         = try(cred.issuer_url, local.cfg.oidc_issuer_url)
          audiences          = try(cred.audiences, ["api://AzureADTokenExchange"])
        }
      }
    }
  }

  # --- Subnet creation (for existing VNet scenarios) ---
  create_subnet           = try(local.cfg.subnet, null) != null
  subnet_name             = try(local.cfg.subnet.name, "snet-aks-nodes-${local.environment}-${local.location}")
  subnet_address_prefixes = try(local.cfg.subnet.address_prefixes, [])
  subnet_vnet_resource_id = try(local.cfg.subnet.vnet_resource_id, "")

  # --- Subnet name (for module-created VNet scenarios) ---
  aks_subnet_name = try(local.cfg.aks_subnet_name, "snet-aks-nodes")
}
