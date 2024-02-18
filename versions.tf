terraform {
  required_version = ">= 0.13"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.11"
    }
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = ">=3.92"
    # }
  }
}

provider "azuredevops" {
  org_service_url = var.org_service_url
}

# provider "azurerm" {
#   subscription_id = var.iac_resources_sub
#   features {}
#   alias = "iac_subscription"
# }