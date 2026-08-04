#########################################################################
##                     Landing Zone Vending                            ##
##  Provisions: Resource Groups, VNet (optional), Identities          ##
#########################################################################

module "lz_vending" {
  source  = "Azure/avm-ptn-alz-sub-vending/azure"
  version = "0.3.0"

  location = var.region

  subscription_alias_enabled                        = false
  subscription_id                                   = var.az_subscription_id
  subscription_management_group_association_enabled = false

  # ---------------------------------------------------------------------------
  # Resource Groups
  # ---------------------------------------------------------------------------
  resource_group_creation_enabled = true
  resource_groups = {
    aks = {
      name     = local.resource_group_name
      location = var.region
      tags     = local.common_tags
    }
  }

  # ---------------------------------------------------------------------------
  # Virtual Network + Subnets (optional - set provision_vnet = true to create)
  # ---------------------------------------------------------------------------
  virtual_network_enabled = var.provision_vnet
  virtual_networks = var.provision_vnet ? {
    aks = {
      name               = "vnet-aks-${var.environment}-${var.region}"
      address_space      = [var.vnet_cidr]
      resource_group_key = "aks"
      location           = var.region
      dns_servers        = var.vnet_dns_servers
      tags               = local.common_tags

      subnets = {
        aks-nodes = {
          name                            = var.subnet_aks_nodes_name
          address_prefixes                = [var.subnet_aks_nodes_cidr]
          default_outbound_access_enabled = false
        }
        aks-apiserver = {
          name                            = var.subnet_aks_apiserver_name
          address_prefixes                = [var.subnet_aks_apiserver_cidr]
          default_outbound_access_enabled = false
          delegations = [{
            name = "aks-delegation"
            service_delegation = {
              name = "Microsoft.ContainerService/managedClusters"
            }
          }]
        }
      }
    }
  } : {}

  # ---------------------------------------------------------------------------
  # User-Assigned Managed Identities
  # ---------------------------------------------------------------------------
  umi_enabled = true
  user_managed_identities = {
    aks-controlplane = {
      name               = "id-aks-controlplane-${var.environment}-${var.region}"
      resource_group_key = "aks"
      location           = var.region
      tags               = local.common_tags
      role_assignments = {
        network_contributor = {
          definition     = "Network Contributor"
          relative_scope = ""
        }
        mio_on_kubelet = {
          definition               = "Managed Identity Operator"
          resource_group_scope_key = "aks"
        }
        dns_zone_contributor = {
          definition               = "Private DNS Zone Contributor"
          relative_scope           = var.provision_controlplane_dns ? null : "/resourceGroups/${data.azurerm_private_dns_zone.aks[0].resource_group_name}"
          resource_group_scope_key = var.provision_controlplane_dns ? "aks" : null
        }
      }
    }
    aks-kubelet = {
      name               = "id-aks-kubelet-${var.environment}-${var.region}"
      resource_group_key = "aks"
      location           = var.region
      tags               = local.common_tags
      role_assignments   = {}
    }
    workload-dns = {
      name               = "id-workload-dns-${var.environment}-${var.region}"
      resource_group_key = "aks"
      location           = var.region
      tags               = local.common_tags
      role_assignments = {
        dns_contributor = {
          definition               = "Private DNS Zone Contributor"
          relative_scope           = var.provision_workload_dns ? null : "/resourceGroups/${data.azurerm_private_dns_zone.workload[0].resource_group_name}"
          resource_group_scope_key = var.provision_workload_dns ? "aks" : null
        }
      }
    }
    workload-eso = {
      name               = "id-workload-eso-${var.environment}-${var.region}"
      resource_group_key = "aks"
      location           = var.region
      tags               = local.common_tags
      role_assignments = var.key_vault_resource_id != "" ? {
        kv_secrets_user = {
          definition     = "Key Vault Secrets User"
          relative_scope = var.key_vault_resource_id
        }
      } : {}
    }
  }

  # ---------------------------------------------------------------------------
  # Budgets (optional)
  # ---------------------------------------------------------------------------
  budget_enabled = var.budget_enabled
  budgets        = var.budgets

  # ---------------------------------------------------------------------------
  # Tags
  # ---------------------------------------------------------------------------
  subscription_tags = local.common_tags

  enable_telemetry = false
}