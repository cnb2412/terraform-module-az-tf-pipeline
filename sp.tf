data "azuread_user" "sp_owner_prod" {
  count = length(var.service_principle_owner_prod) > 0 ? 1 : 0
  user_principal_name = var.service_principle_owner_prod
}

data "azuread_user" "sp_owner_test" {
  count = length(var.service_principle_owner_test) > 0 ? 1 : 0
  user_principal_name = var.service_principle_owner_test
}

resource "azuread_application" "az_devoops_app_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  display_name = "AzDevOps_${var.devops_project_name}_prod_sp"
  owners       = length(var.service_principle_owner_prod) > 0 ? [data.azuread_user.sp_owner_prod[0].object_id] : []
  description = "Used by Azure DevOps Project ${var.devops_project_name} to deploy to prod. Created by TF." 
}

resource "azuread_application" "az_devoops_app_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  display_name = "AzDevOps_${var.devops_project_name}_test_sp"
  owners       = length(var.service_principle_owner_test) > 0 ? [data.azuread_user.sp_owner_test[0].object_id] : []
  description = "Used by Azure DevOps Project ${var.devops_project_name} to deploy to test. Created by TF."
}

resource "azuread_service_principal" "az_sp_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  client_id               = azuread_application.az_devoops_app_prod[0].client_id
  app_role_assignment_required = false
  owners       = length(var.service_principle_owner_prod) > 0 ? [data.azuread_user.sp_owner_prod[0].object_id] : []
  description = "Used by Azure DevOps Project ${var.devops_project_name} to deploy to prod. Created by TF." 
}

resource "azuread_service_principal" "az_sp_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  client_id               = azuread_application.az_devoops_app_test[0].client_id
  app_role_assignment_required = false
  owners       = length(var.service_principle_owner_test) > 0 ? [data.azuread_user.sp_owner_test[0].object_id] : []
  description = "Used by Azure DevOps Project ${var.devops_project_name} to deploy to test. Created by TF." 
}

resource "azuread_service_principal_password" "az_sp_pwd_prod" {
    count = !var.remove && var.create_service_principle_prod ? 1 : 0
    service_principal_id = azuread_service_principal.az_sp_prod[0].object_id
    display_name = "Az-DevOps_secret_prod"
    # end_date = "2023-10-01T01:02:03Z"
}

resource "azuread_service_principal_password" "az_sp_pwd_test" {
    count = !var.remove && var.create_service_principle_test ? 1 : 0
    service_principal_id = azuread_service_principal.az_sp_test[0].object_id
    display_name = "Az-DevOps_secret_test"
    # end_date = "2023-10-01T01:02:03Z"
}