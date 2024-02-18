terraform {
  required_version = ">= 0.13"
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">= 0.11"
    }
  }
}