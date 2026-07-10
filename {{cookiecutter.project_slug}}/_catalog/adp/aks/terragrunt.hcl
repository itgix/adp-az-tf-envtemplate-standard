# =============================================================================
# Catalog: adp/aks
# Shared module logic for all ADP AKS deployments.
# Environment-specific values come from values.yaml in each leaf folder.
# Subnet and resource group are passed via values.yaml since lz-vending
# lives in a separate folder hierarchy.
# =============================================================================

terraform {
  source = "git::https://github.com/Azure/terraform-azurerm-avm-res-containerservice-managedcluster?ref=v0.6.6"
}

exclude {
  if                   = !local.feature_enabled
  actions              = ["all"]
  exclude_dependencies = false
}

generate "pre_aks_roles" {
  path      = "pre_aks_roles.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
variable "controlplane_principal_id" { type = string }
variable "private_dns_zone_id"       { type = string; default = "" }

resource "azurerm_role_assignment" "controlplane_private_dns" {
  count                = var.private_dns_zone_id != "" ? 1 : 0
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = var.controlplane_principal_id
}
EOF
}

dependency "networking" {
  config_path = "${get_original_terragrunt_dir()}/../networking"

  mock_outputs = {
    virtual_network_resource_ids = {
      vnet = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks-dev-swedencentral/providers/Microsoft.Network/virtualNetworks/vnet-aks-dev-swedencentral"
    }
    umi_resource_ids  = {
      kubelet      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks-dev-swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-aks-kubelet"
      controlplane = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks-dev-swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-aks-controlplane"
    }
    umi_client_ids    = { kubelet = "00000000-0000-0000-0000-000000000000", controlplane = "00000000-0000-0000-0000-000000000000" }
    umi_principal_ids = { kubelet = "00000000-0000-0000-0000-000000000000", controlplane = "00000000-0000-0000-0000-000000000000" }
  }
  mock_outputs_merge_with_state = true
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
  name                = "aks-${local.environment}-${local.location}"
  location            = local.location
  resource_group_name = local.cfg.resource_group_name
  parent_id           = "/subscriptions/${local.subscription_id}/resourceGroups/${local.cfg.resource_group_name}"
  kubernetes_version  = local.cfg.kubernetes_version

  # Networking - Azure CNI Overlay
  network_profile = {
    network_plugin      = local.cfg.network_profile.network_plugin
    network_plugin_mode = local.cfg.network_profile.network_plugin_mode
  }

  # Default node pool
  default_agent_pool = {
    name                = "systempool"
    vm_size             = local.cfg.node_pool.vm_size
    min_count           = local.cfg.node_pool.min_count
    max_count           = local.cfg.node_pool.max_count
    enable_auto_scaling = true
    vnet_subnet_id      = "${dependency.networking.outputs.virtual_network_resource_ids["vnet"]}/subnets/${local.cfg.aks_subnet_name}"
  }

  node_pools = try(local.cfg.node_pools, {})

  role_assignments = try(local.cfg.role_assignments, {})

  node_resource_group = try(local.cfg.node_resource_group, null)

  api_server_access_profile = {
    authorized_ip_ranges    = try(local.cfg.api_server_access_profile.ip_ranges, null)
    enable_private_cluster  = try(local.cfg.api_server_access_profile.private_cluster, false)
    private_dns_zone        = try(local.cfg.api_server_access_profile.private_dns_zone, null)
    enable_vnet_integration = try(local.cfg.api_server_access_profile.enable_vnet_integration, false)
    subnet_id               = try(local.cfg.api_server_access_profile.subnet_id, null)
  }

  aad_profile = {
    admin_group_object_ids = try(local.cfg.aad_profile.admin_group_object_ids, null)
    enable_azure_rbac      = try(local.cfg.aad_profile.enable_azure_rbac, true)
    managed                = try(local.cfg.aad_profile.managed, true)
    tenant_id              = try(local.cfg.aad_profile.tenant_id, null)
  }

  identity_profile = {
    kubeletidentity = {
      resource_id = dependency.networking.outputs.umi_resource_ids["kubelet"]
      client_id   = dependency.networking.outputs.umi_client_ids["kubelet"]
      object_id   = dependency.networking.outputs.umi_principal_ids["kubelet"]
    }
  }

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [dependency.networking.outputs.umi_resource_ids["controlplane"]]
  }

  # Workload Identity + OIDC
  oidc_issuer_profile = {
    enabled = true
  }
  security_profile = {
    workload_identity = {
      enabled = true
    }
  }

  addon_profile_azure_policy = {
    enabled = true
  }

  tags = local.tags

  controlplane_principal_id = dependency.networking.outputs.umi_principal_ids["controlplane"]
  private_dns_zone_id       = try(local.cfg.api_server_access_profile.private_dns_zone, "")
}
