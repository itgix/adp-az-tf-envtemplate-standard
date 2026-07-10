locals {
  null_source = "${get_repo_root()}/_null"

  tenant_id                = "{{ cookiecutter.tenant_id }}"
  root_management_group_id = "{{ cookiecutter.client_name }}"

  default_tags = {
    ManagedBy = "terragrunt"
    IaCRepo   = "{{ cookiecutter.project_slug }}"
  }

  enable_telemetry = false

  subscription_vars = try(read_terragrunt_config(find_in_parent_folders("subscription.hcl")), { locals = {} })
  region_vars       = try(read_terragrunt_config(find_in_parent_folders("region.hcl")), { locals = {} })

  location        = try(local.region_vars.locals.location, "")
  subscription_id = try(local.subscription_vars.locals.subscription_id, "")
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
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

    provider "azurerm" {
      features {}
      subscription_id     = "${local.subscription_id}"
      tenant_id           = "${local.tenant_id}"
      use_oidc            = true
      storage_use_azuread = true
    }

    provider "azapi" {
      subscription_id = "${local.subscription_id}"
      tenant_id       = "${local.tenant_id}"
      use_oidc        = true
    }
EOF
}

remote_state {
  backend = "azurerm"
  config = {
    subscription_id      = "{{ cookiecutter.subscription_id }}"
    resource_group_name  = "{{ cookiecutter.state_resource_group }}"
    storage_account_name = "{{ cookiecutter.state_storage_account }}"
    container_name       = "{{ cookiecutter.state_container }}"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    use_azuread_auth     = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  try(local.subscription_vars.locals, {}),
  try(local.region_vars.locals, {}),
)
