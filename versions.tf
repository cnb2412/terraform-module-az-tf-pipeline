terraform {
  required_version = ">= 0.13"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.11"
    }
  }
}

provider "azuredevops" {
  org_service_url = var.org_service_url
}