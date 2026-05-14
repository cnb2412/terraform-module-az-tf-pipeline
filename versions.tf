terraform {
  required_version = ">= 1.5"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azuredevops" {
  org_service_url = var.org_service_url
}

provider "azurerm" {
  subscription_id     = var.iac_resources_sub
  storage_use_azuread = true
  features {}
  alias = "iac_subscription"
}
