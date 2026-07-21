locals {
  environment = "__ENV__"

  tags = {
    Environment = "__ENV__"
  }

  features = {
    networking   = __CREATE_NETWORKING__
    aks          = __CREATE_AKS__
    azure_policy = __CREATE_AZURE_POLICY__
    identities   = __CREATE_IDENTITIES__
    postgresql   = __CREATE_POSTGRES__
  }
}
