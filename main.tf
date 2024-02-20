/******************************************
  Azure DevOps project and repo
*******************************************/
resource "azuredevops_project" "myproject" {
  count = var.remove ? 0 : 1
  name               = var.devops_project_name
  visibility         = var.public_project ? "public" : "private"
  version_control    = "Git"
  work_item_template = "Basic"
    features = {
    "testplans" = "disabled"
    "artifacts" = "disabled"
    "boards"    = "disabled"
  }
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

/******************************************
  Azure DevOps project: Service Connection
*******************************************/
resource "azuredevops_serviceendpoint_azurerm" "arm_serviceconnection_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  project_id = azuredevops_project.myproject[0].id
  service_endpoint_name                  = "AzConn_Prod"
  description                            = "Connection to AZ Test. Managed by Terraform"
  credentials {
    serviceprincipalid  = azuread_service_principal.az_sp_prod[0].object_id
    serviceprincipalkey = azuread_service_principal_password.az_sp_pwd_prod[0].value
  }
  azurerm_spn_tenantid          = azuread_service_principal.az_sp_prod[0].application_tenant_id
  azurerm_subscription_id   = var.deployment_prod_sub
  azurerm_subscription_name = "Prod subscription"
}
resource "azuredevops_serviceendpoint_azurerm" "arm_serviceconnection_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  project_id = azuredevops_project.myproject[0].id
  service_endpoint_name                  = "AzConn_Test"
  description                            = "Connection to AZ Test. Managed by Terraform"
  credentials {
    serviceprincipalid  = azuread_service_principal.az_sp_test[0].object_id
    serviceprincipalkey = azuread_service_principal_password.az_sp_pwd_test[0].value
  }
  azurerm_spn_tenantid          = azuread_service_principal.az_sp_test[0].application_tenant_id
  azurerm_subscription_id   = var.deployment_test_sub
  azurerm_subscription_name = "Test subscription"
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