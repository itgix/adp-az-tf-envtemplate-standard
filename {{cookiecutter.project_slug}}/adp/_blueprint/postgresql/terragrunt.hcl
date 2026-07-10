include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "module" {
  path   = "${get_repo_root()}/_catalog/adp/postgresql/terragrunt.hcl"
  expose = true
}
