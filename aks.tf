#########################################################################
##                     AKS Cluster                                    ##
#########################################################################

module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.7.1"

  count = var.provision_aks ? 1 : 0

  location  = var.region
  name      = "aks-${var.project_name}-${var.environment}-${var.region}"
  parent_id = module.lz_vending.resource_group_resource_ids["aks"]

  kubernetes_version = var.aks_cluster_version

  node_resource_group = local.aks_node_resource_group_name

  #---------------------------------------------------------------------------
  # SKU & Support
  #---------------------------------------------------------------------------
  sku = var.aks_sku

  #---------------------------------------------------------------------------
  # Identity - User Assigned (recommended over system-assigned for AKS)
  #---------------------------------------------------------------------------
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.lz_vending.umi_resource_ids["aks-controlplane"]]
  }

  identity_profile = {
    kubeletidentity = {
      resource_id = var.provision_kubelet_identity ? module.lz_vending.umi_resource_ids["aks-kubelet"] : data.azurerm_user_assigned_identity.kubelet[0].id
    }
  }

  #---------------------------------------------------------------------------
  # API Server Access - Private Cluster with VNet Integration
  #---------------------------------------------------------------------------
  api_server_access_profile = {
    enable_private_cluster             = var.aks_private_cluster
    enable_vnet_integration            = true
    subnet_id                          = var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_aks_apiserver_name}" : azurerm_subnet.aks_apiserver[0].id
    enable_private_cluster_public_fqdn = !var.aks_private_cluster
    disable_run_command                = false
    private_dns_zone                   = var.aks_private_cluster ? local.aks_private_dns_zone_id : null
  }

  #---------------------------------------------------------------------------
  # Network Profile - Azure CNI Overlay + Cilium
  #---------------------------------------------------------------------------
  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_dataplane   = "cilium"
    network_policy      = "cilium"
    service_cidr        = "172.16.0.0/16"
    dns_service_ip      = "172.16.0.10"
    pod_cidr            = "192.168.0.0/16"
    load_balancer_sku   = "standard"
    outbound_type       = var.aks_outbound_type
  }

  #---------------------------------------------------------------------------
  # Default (System) Node Pool
  #---------------------------------------------------------------------------
  default_agent_pool = merge(var.aks_system_pool, {
    vnet_subnet_id = var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_aks_nodes_name}" : azurerm_subnet.aks_nodes[0].id
  })

  #---------------------------------------------------------------------------
  # Additional Node Pools
  #---------------------------------------------------------------------------
  agent_pools = {
    for k, v in var.aks_worker_pools : k => merge(v, {
      vnet_subnet_id = var.provision_vnet ? "${local.vnet_id}/subnets/${local.subnet_aks_nodes_name}" : azurerm_subnet.aks_nodes[0].id
    })
  }

  #---------------------------------------------------------------------------
  # Auto Upgrade
  #---------------------------------------------------------------------------
  auto_upgrade_profile = {
    upgrade_channel         = "patch"
    node_os_upgrade_channel = "NodeImage"
  }

  #---------------------------------------------------------------------------
  # OIDC + Workload Identity
  #---------------------------------------------------------------------------
  oidc_issuer_profile = {
    enabled = true
  }

  security_profile = {
    workload_identity = {
      enabled = true
    }

    image_cleaner = {
      enabled        = true
      interval_hours = 48
    }
  }

  #---------------------------------------------------------------------------
  # Azure AD Integration + RBAC
  #---------------------------------------------------------------------------
  aad_profile = {
    managed                = true
    enable_azure_rbac      = true
    admin_group_object_ids = var.aks_admin_group_ids
  }

  disable_local_accounts = true
  enable_rbac            = true

  #---------------------------------------------------------------------------
  # Storage Profile
  #---------------------------------------------------------------------------
  storage_profile = {
    blob_csi_driver = {
      enabled = false
    }

    disk_csi_driver = {
      enabled = true
    }

    file_csi_driver = {
      enabled = true
    }

    snapshot_controller = {
      enabled = true
    }
  }

  #---------------------------------------------------------------------------
  # Monitoring - Azure Monitor (Managed Prometheus)
  #---------------------------------------------------------------------------
  azure_monitor_profile = var.aks_prometheus_workspace_id != null ? {
    metrics = {
      enabled = true
      kube_state_metrics = {
        metric_annotations_allow_list = ""
        metric_labels_allowlist       = ""
      }
    }
  } : null

  prometheus_workspace_id = var.aks_prometheus_workspace_id

  #---------------------------------------------------------------------------
  # Addon Profiles
  #---------------------------------------------------------------------------
  addon_profile_azure_policy = {
    enabled = true
  }

  addon_profile_key_vault_secrets_provider = {
    enabled = true
    config = {
      enable_secret_rotation = true
      rotation_poll_interval = "2m"
    }
  }

  #---------------------------------------------------------------------------
  # Maintenance Windows
  #---------------------------------------------------------------------------
  maintenanceconfiguration = var.aks_maintenance_windows

  #---------------------------------------------------------------------------
  # Ingress Profile  
  #---------------------------------------------------------------------------
  # Set to Disabled to work around validation bug in AKS AVM module 0.7.1
  # The validation fails with null or empty values due to coalesce() error
  ingress_profile = {
    gateway_api = {
      installation = "Disabled"
    }
    web_app_routing = {
      gateway_api_implementations = {
        app_routing_istio = {
          mode = "Disabled"
        }
      }
    }
  }

  #---------------------------------------------------------------------------
  # Tags
  #---------------------------------------------------------------------------
  tags = local.common_tags

  role_assignments = {
    cluster_admin = {
      role_definition_id_or_name = "Azure Kubernetes Service RBAC Cluster Admin"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }

  enable_telemetry = false

  depends_on = [
    module.lz_vending,
  ]
}
