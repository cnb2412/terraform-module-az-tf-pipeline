resource "azuredevops_project" "myproject" {
  name               = var.devops_project_name
  visibility         = var.public_project ? "public" : "private"
  version_control    = "Git"
  work_item_template = ""
}

locals {
  repo_name = length(var.repo_name) > 0 ? var.repo_name : "${var.devops_project_name}_repo"
}
resource "azuredevops_git_repository" "myrepo" {
  project_id = azuredevops_project.myproject.id
  name       = local.repo_name
  initialization {
    init_type = "Clean"
  }
}

# Disable unsued features
# Todo: use vars to make it configurabe
resource "azuredevops_project_features" "devops-features" {
  project_id = azuredevops_project.myproject.id
  features = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
    "boards"    = "disabled"
  }
}

data "azurerm_resource_group" "iac_rg" {
  name = var.iac_ressources_rg
  provider = azurerm.iac_subscription
}

## Storage account for TF states
resource "azurerm_storage_account" "tf-state-bucket" {
  name                = "${var.resource_prefix}tfs"
  resource_group_name = data.azurerm_resource_group.iac_rg.name
  location            = data.azurerm_resource_group.iac_rg.location
  blob_properties {
    versioning_enabled = true
  }
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  cross_tenant_replication_enabled = false
  enable_https_traffic_only        = true
  provider = azurerm.iac_subscription
}