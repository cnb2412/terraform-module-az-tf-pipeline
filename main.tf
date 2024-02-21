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
  Get some data from the Iac infra
*******************************************/
data "azurerm_resource_group" "iac_rg" {
  count = var.remove ? 0 : 1
  name = var.iac_ressources_rg
  provider = azurerm.iac_subscription
}

data "azurerm_subscription" "current" {
}

data "azurerm_subscription" "deployment_prod" {
  count = length(var.deployment_prod_sub_id) > 0 ? 1 : 0
  subscription_id = var.deployment_prod_sub_id
}

data "azurerm_subscription" "deployment_test" {
  count = length(var.deployment_test_sub_id) > 0 ? 1 : 0
  subscription_id = var.deployment_test_sub_id
}

/******************************************
  Azure DevOps project: Service Connection
*******************************************/
resource "azurerm_user_assigned_identity" "managed_identity_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  location            = data.azurerm_resource_group.iac_rg[0].location
  name                = "${var.resource_prefix}_p_id"
  resource_group_name = var.iac_ressources_rg
}
resource "azurerm_user_assigned_identity" "managed_identity_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  location            = data.azurerm_resource_group.iac_rg[0].location
  name                = "${var.resource_prefix}_t_id"
  resource_group_name = var.iac_ressources_rg
}

resource "azuredevops_serviceendpoint_azurerm" "arm_serviceconnection_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  project_id                             = azuredevops_project.myproject[0].id
  service_endpoint_name                  = "AzConn_Prod"
  description                            = "Connection to AZ Prod. Managed by Terraform"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  credentials {
    serviceprincipalid = azurerm_user_assigned_identity.managed_identity_prod[0].client_id
  }
  azurerm_spn_tenantid      = length(var.deployment_prod_tenant_id) > 0 ? var.deployment_prod_tenant_id : data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = var.deployment_prod_sub_id
  azurerm_subscription_name = "Prod subscription"
}

resource "azuredevops_serviceendpoint_azurerm" "arm_serviceconnection_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  project_id                             = azuredevops_project.myproject[0].id
  service_endpoint_name                  = "AzConn_Test"
  description                            = "Connection to AZ Test. Managed by Terraform"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  credentials {
    serviceprincipalid = azurerm_user_assigned_identity.managed_identity_test[0].client_id
  }
  azurerm_spn_tenantid      = length(var.deployment_test_tenant_id) > 0 ? var.deployment_test_tenant_id : data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = var.deployment_test_sub_id
  azurerm_subscription_name = "Test subscription"
}

resource "azurerm_federated_identity_credential" "prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  name                = "${var.resource_prefix}-federated-credential_prod"
  resource_group_name = var.iac_ressources_rg
  parent_id           = azurerm_user_assigned_identity.managed_identity_prod[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azuredevops_serviceendpoint_azurerm.arm_serviceconnection_prod[0].workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurerm.arm_serviceconnection_prod[0].workload_identity_federation_subject
}

resource "azurerm_federated_identity_credential" "test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  name                = "${var.resource_prefix}-federated-credential_test"
  resource_group_name = var.iac_ressources_rg
  parent_id           = azurerm_user_assigned_identity.managed_identity_test[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azuredevops_serviceendpoint_azurerm.arm_serviceconnection_test[0].workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurerm.arm_serviceconnection_test[0].workload_identity_federation_subject
}

/******************************************
  Permissions for managed identities
*******************************************/

resource "azurerm_role_assignment" "az_sa_role_assignment_prod" {
  count = !var.remove && var.create_service_principle_prod ? 1 : 0
  scope              = data.azurerm_subscription.deployment_prod[0].id
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.managed_identity_prod[0].principal_id
}
resource "azurerm_role_assignment" "az_sa_role_assignment_test" {
  count = !var.remove && var.create_service_principle_test ? 1 : 0
  scope              = data.azurerm_subscription.deployment_test[0].id
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.managed_identity_test[0].principal_id
}

/******************************************
  TF IaC ressources
*******************************************/
locals {
  tf_bk_sa_name = "${var.resource_prefix}tfs"
  tf_bk_sc_name = "${var.resource_prefix}tfsc"
}
## Storage account for TF states
resource "azurerm_storage_account" "tf-state-bucket" {
  count = var.remove ? 0 : 1
  name                = local.tf_bk_sa_name
  resource_group_name = data.azurerm_resource_group.iac_rg[0].name
  location            = data.azurerm_resource_group.iac_rg[0].location
  blob_properties {
    versioning_enabled = true
  }
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  cross_tenant_replication_enabled = false
  enable_https_traffic_only        = true
  provider = azurerm.iac_subscription
}
resource "azurerm_storage_container" "tf-state-container" {
  count = var.remove ? 0 : 1
  name                  = local.tf_bk_sc_name
  storage_account_name  = azurerm_storage_account.tf-state-bucket[0].name
  container_access_type = "blob"
}

/******************************************
  Azure DevOps pipeline
*******************************************/

locals {
  yml_path_prod = "azure-pipeline-prod.yml"
  yml_path_test = "azure-pipeline-test.yml"
}
resource "azuredevops_build_definition" "build_prod" {
  count = !var.remove && var.create_prod_pipeline ? 1 : 0
  project_id = azuredevops_project.myproject[0].id
  name       = "${var.resource_prefix} Prod Deploy"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.myrepo[0].id
    branch_name = azuredevops_git_repository.myrepo[0].default_branch
    yml_path    = local.yml_path_prod
  }
  ci_trigger {
    use_yaml = true
  }
}

resource "azuredevops_build_definition" "build_test" {
  count = !var.remove && var.create_test_pipeline ? 1 : 0
  project_id = azuredevops_project.myproject[0].id
  name       = "${var.resource_prefix} Test Deploy"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.myrepo[0].id
    branch_name = azuredevops_git_repository.myrepo[0].default_branch
    yml_path    = local.yml_path_test
  }
  ci_trigger {
    use_yaml = true
  }
}

resource "azuredevops_git_repository_file" "pipeline_file_prod" {
  count = !var.remove && var.create_prod_pipeline ? 1 : 0
  repository_id       = azuredevops_git_repository.myrepo[0].id
  branch = azuredevops_git_repository.myrepo[0].default_branch
  file                = local.yml_path_prod
  content             = templatefile("${path.module}/azure-pipelines-prod.yml", { "default_branch" = azuredevops_git_repository.myrepo[0].default_branch,
    "serviceconnection" = azuredevops_serviceendpoint_azurerm.arm_serviceconnection_prod[0].service_endpoint_name,
    "tf_bk_rg" = data.azurerm_resource_group.iac_rg[0].name,
    "tf_bk_sa" = local.tf_bk_sa_name,
    "tf_bk_sc" = local.tf_bk_sc_name})
  commit_message      = "add ${local.yml_path_prod}"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [commit_message]
  }
}

resource "azuredevops_git_repository_file" "pipeline_file_test" {
  count = !var.remove && var.create_test_pipeline ? 1 : 0
  repository_id       = azuredevops_git_repository.myrepo[0].id
  branch = azuredevops_git_repository.myrepo[0].default_branch
  file                = local.yml_path_test
  content             = templatefile("${path.module}/azure-pipelines-test.yml", {
    "default_branch" = azuredevops_git_repository.myrepo[0].default_branch })
  commit_message      = "add ${local.yml_path_test}"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [commit_message]
  }
}