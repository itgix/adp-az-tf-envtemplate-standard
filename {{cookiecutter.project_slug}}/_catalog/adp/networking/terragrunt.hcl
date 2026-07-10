terraform {
  source = "git::https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending?ref=v0.1.1"
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

generate "controlplane_kubelet_role" {
  path      = "controlplane_kubelet_role.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
resource "azurerm_role_assignment" "controlplane_kubelet_operator" {
  scope                = module.usermanagedidentity["kubelet"].resource_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.usermanagedidentity["controlplane"].principal_id
}
EOF
}

inputs = {
  location        = local.location
  subscription_id = local.subscription_id

  subscription_enabled                              = false
  subscription_management_group_association_enabled = false
  umi_enabled             = true
  user_managed_identities = {
    for k, v in try(local.cfg.user_managed_identities, {}) :
    k => {
      name               = v.name
      location           = local.location
      resource_group_key = "aks"
      tags               = merge(local.tags, try(v.tags, {}))
    }
  }
  budget_enabled                                    = false
  role_assignment_enabled                           = false
  disable_telemetry                                 = !local.root_vars.locals.enable_telemetry

  resource_group_creation_enabled = true
  resource_groups = {
    aks = {
      name     = try(local.cfg.resource_group_name, "rg-aks-${local.environment}-${local.location}")
      location = local.location
      tags     = local.tags
    }
  }

  virtual_network_enabled = true
  virtual_networks = {
    vnet = {
      name               = try(local.cfg.vnet.name, "vnet-aks-${local.environment}-${local.location}")
      address_space      = local.cfg.vnet.address_space
      location           = local.location
      resource_group_key = "aks"
      tags               = merge(local.tags, try(local.cfg.vnet.tags, {}))

      subnets = {
        for s in local.cfg.vnet.subnets :
        s.key => {
          name             = s.name
          address_prefixes = s.cidrs

          network_security_group = {
            key_reference = "nsg-${s.key}"
          }
        }
      }
    }
  }

  network_security_group_enabled = true
  network_security_groups = {
    for s in local.cfg.vnet.subnets :
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
  }

}
