terraform {
  source = "${get_repo_root()}/_catalog/adp/azure-policy//"
}

generate "policy_assignment" {
  path      = "main.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "subscription_id" {}
variable "resource_group_name" {}
variable "environment" {}

locals {
  scope = "/subscriptions/$${var.subscription_id}/resourceGroups/$${var.resource_group_name}"

  excluded_namespaces = [
    "kube-system",
    "gatekeeper-system",
    "azure-arc",
    "azure-extensions-usage-system",
    "monitoring",
    "falco",
    "trivy-operator",
    "fluent-bit",
    "argocd",
    "traefik",
    "external-secrets",
  ]
}

resource "azurerm_resource_group_policy_assignment" "k8s_restricted" {
  name                 = "k8s-restricted-$${var.environment}"
  resource_group_id    = local.scope
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00"

  parameters = jsonencode({
    excludedNamespaces = { value = local.excluded_namespaces }
    effect             = { value = "Audit" }
  })
}
EOF
}

exclude {
  if                   = !local.feature_enabled
  actions              = ["all"]
  exclude_dependencies = false
}

locals {
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))
  env_vars          = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  subscription_id = local.subscription_vars.locals.subscription_id
  environment     = local.env_vars.locals.environment

  features        = try(local.env_vars.locals.features, {})
  feature_key     = replace(basename(get_original_terragrunt_dir()), "-", "_")
  feature_enabled = try(local.features[local.feature_key], false)

  cfg = try(yamldecode(file("${get_original_terragrunt_dir()}/values.yaml")), {})
}

inputs = {
  subscription_id     = local.subscription_id
  resource_group_name = local.cfg.resource_group_name
  environment         = local.environment
}
