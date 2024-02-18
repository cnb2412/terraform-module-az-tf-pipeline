resource "azuredevops_project" "myproject" {
  count = var.remove ? 0 : 1
  name               = var.devops_project_name
  visibility         = var.public_project ? "public" : "private"
  version_control    = "Git"
  work_item_template = ""
}

locals {
  repo_name = length(var.repo_name) > 0 ? var.repo_name : "${var.devops_project_name}_repo"
}
resource "azuredevops_git_repository" "myrepo" {
  count = var.remove ? 0 : 1
  project_id = azuredevops_project.myproject[0].id
  name       = local.repo_name
  initialization {
    init_type = "Clean"
  }
}

# Disable unsued features
# Todo: use vars to make it configurabe
resource "azuredevops_project_features" "devops-features" {
  count = var.remove ? 0 : 1
  project_id = azuredevops_project.myproject[0].id
  features = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
    "boards"    = "disabled"
  }
}

# data "azurerm_resource_group" "iac_rg" {
#   count = var.remove ? 0 : 1
#   name = var.iac_ressources_rg
#   provider = azurerm.iac_subscription
# }

# ## Storage account for TF states
# resource "azurerm_storage_account" "tf-state-bucket" {
#   count = var.remove ? 0 : 1
#   name                = "${var.resource_prefix}tfs"
#   resource_group_name = data.azurerm_resource_group.iac_rg[0].name
#   location            = data.azurerm_resource_group.iac_rg[0].location
#   blob_properties {
#     versioning_enabled = true
#   }
#   account_tier                     = "Standard"
#   account_replication_type         = "GRS"
#   cross_tenant_replication_enabled = false
#   enable_https_traffic_only        = true
#   provider = azurerm.iac_subscription
# }