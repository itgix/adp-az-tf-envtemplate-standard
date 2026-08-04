locals {
  resource_group_name = "rg-aks-${var.environment}-${var.region}"

  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}
