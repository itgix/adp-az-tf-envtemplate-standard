#########################################################################
##  AKS Cluster
#########################################################################

output "aks_cluster_id" {
  description = "The resource ID of the AKS cluster"
  value       = var.provision_aks ? module.aks[0].resource_id : null
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = var.provision_aks ? module.aks[0].name : null
}

output "aks_cluster_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = var.provision_aks ? module.aks[0].fqdn : null
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL of the AKS cluster"
  value       = var.provision_aks ? module.aks[0].oidc_issuer_profile_issuer_url : null
}

output "aks_kubelet_identity_client_id" {
  description = "Client ID of the kubelet managed identity"
  value       = module.lz_vending.umi_client_ids["aks-kubelet"]
}

output "aks_controlplane_identity_client_id" {
  description = "Client ID of the control plane managed identity"
  value       = module.lz_vending.umi_client_ids["aks-controlplane"]
}

output "aks_controlplane_identity_id" {
  description = "Resource ID of the control plane managed identity"
  value       = module.lz_vending.umi_resource_ids["aks-controlplane"]
}

#########################################################################
##  Networking
#########################################################################

output "subnet_aks_nodes_id" {
  description = "Resource ID of the AKS nodes subnet"
  value       = var.provision_vnet ? "${module.lz_vending.virtual_network_resource_ids["aks"]}/subnets/${var.subnet_aks_nodes_name}" : azurerm_subnet.aks_nodes[0].id
}

output "subnet_aks_apiserver_id" {
  description = "Resource ID of the AKS API server subnet"
  value       = var.provision_vnet ? "${module.lz_vending.virtual_network_resource_ids["aks"]}/subnets/${var.subnet_aks_apiserver_name}" : azurerm_subnet.aks_apiserver[0].id
}

output "vnet_id" {
  description = "Resource ID of the VNet"
  value       = var.provision_vnet ? module.lz_vending.virtual_network_resource_ids["aks"] : data.azurerm_virtual_network.vnet[0].id
}

#########################################################################
##  Resource Group
#########################################################################

output "resource_group_name" {
  description = "Name of the AKS resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "Resource ID of the AKS resource group"
  value       = module.lz_vending.resource_group_resource_ids["aks"]
}

#########################################################################
##  DNS Zones
#########################################################################

output "aks_private_dns_zone_id" {
  description = "Resource ID of the AKS control plane private DNS zone"
  value       = var.provision_controlplane_dns ? azurerm_private_dns_zone.aks[0].id : data.azurerm_private_dns_zone.aks[0].id
}

output "workload_private_dns_zone_id" {
  description = "Resource ID of the workload private DNS zone"
  value       = var.provision_workload_dns ? azurerm_private_dns_zone.workload[0].id : data.azurerm_private_dns_zone.workload[0].id
}

output "public_dns_zone_id" {
  description = "Resource ID of the public DNS zone"
  value       = var.provision_public_dns ? azurerm_dns_zone.public[0].id : null
}

#########################################################################
##  Workload Identities
#########################################################################

output "workload_dns_identity_client_id" {
  description = "Client ID of the external-dns workload identity"
  value       = module.lz_vending.umi_client_ids["workload-dns"]
}

output "workload_eso_identity_client_id" {
  description = "Client ID of the ESO workload identity"
  value       = module.lz_vending.umi_client_ids["workload-eso"]
}
