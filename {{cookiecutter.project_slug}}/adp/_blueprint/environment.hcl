locals {
  environment = "__ENV__"

  tags = {
    Environment = "__ENV__"
  }

  features = {
    networking   = true
    aks          = true
    identities   = true
    postgresql   = true
  }
}
