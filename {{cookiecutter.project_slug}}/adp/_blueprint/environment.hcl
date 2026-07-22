locals {
  environment = "__ENV__"

  tags = {
    Environment = "__ENV__"
  }

  features = {
    lz_vending   = __CREATE_LZ_VENDING__
    aks          = __CREATE_AKS__
    azure_policy = __CREATE_AZURE_POLICY__
    postgresql   = __CREATE_POSTGRES__
  }
}
