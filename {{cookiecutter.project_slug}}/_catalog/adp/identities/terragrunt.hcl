terraform {
  source = "${get_repo_root()}/_catalog/adp/identities//"
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.5"
    }
  }
}

variable "subscription_id" {}
variable "location" {}
variable "oidc_issuer_url" {}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "identities" {
  type = map(object({
    name                 = string
    resource_group_name  = string
    role_definition_name = optional(string)
    scope_resource_id    = optional(string)
    federated_credentials_advanced = optional(map(object({
      name               = string
      subject_identifier = string
      issuer_url         = optional(string)
      audiences          = optional(set(string), ["api://AzureADTokenExchange"])
    })), {})
  }))
}

module "identity" {
  source   = "git::https://github.com/Azure/terraform-azure-avm-ptn-alz-sub-vending//modules/user-assigned-managed-identity?ref=v0.1.1"
  for_each = var.identities

  name      = each.value.name
  location  = var.location
  parent_id = "/subscriptions/$${var.subscription_id}/resourceGroups/$${each.value.resource_group_name}"
  tags      = var.tags

  federated_credentials_advanced = {
    for cred_key, cred in each.value.federated_credentials_advanced :
    cred_key => {
      name               = cred.name
      subject_identifier = cred.subject_identifier
      issuer_url         = coalesce(cred.issuer_url, var.oidc_issuer_url)
      audiences          = cred.audiences
    }
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = {
    for k, v in var.identities : k => v
    if v.scope_resource_id != null && v.role_definition_name != null
  }
  scope                = each.value.scope_resource_id
  role_definition_name = each.value.role_definition_name
  principal_id         = module.identity[each.key].principal_id
}

output "identity_resource_ids" {
  value = { for k, v in module.identity : k => v.resource_id }
}

output "identity_client_ids" {
  value = { for k, v in module.identity : k => v.client_id }
}

output "identity_principal_ids" {
  value = { for k, v in module.identity : k => v.principal_id }
}
EOF
}

exclude {
  if                   = !local.feature_enabled
  actions              = ["all"]
  exclude_dependencies = false
}

dependency "aks" {
  config_path = "${get_original_terragrunt_dir()}/../aks"

  mock_outputs = {
    oidc_issuer_url = "https://oidc.prod-aks.azure.com/00000000-0000-0000-0000-000000000000/00000000-0000-0000-0000-000000000000/"
  }
  mock_outputs_merge_with_state = true
}

locals {
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars          = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  subscription_id = local.subscription_vars.locals.subscription_id
  location        = local.region_vars.locals.location
  environment     = local.env_vars.locals.environment

  features        = try(local.env_vars.locals.features, {})
  feature_key     = replace(basename(get_original_terragrunt_dir()), "-", "_")
  feature_enabled = try(local.features[local.feature_key], false)

  root_vars      = read_terragrunt_config("${get_repo_root()}/root.hcl")
  cfg            = try(yamldecode(file("${get_original_terragrunt_dir()}/values.yaml")), {})
  inherited_tags = try(local.env_vars.locals.tags, {})
  default_tags   = local.root_vars.locals.default_tags
  tags           = merge(local.default_tags, local.inherited_tags, try(local.cfg.tags, {}))
}

inputs = {
  subscription_id = local.subscription_id
  location        = local.location
  oidc_issuer_url = dependency.aks.outputs.oidc_issuer_url
  tags            = local.tags
  identities      = local.cfg.identities
}
