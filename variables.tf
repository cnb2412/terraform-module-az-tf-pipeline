variable "org_service_url" {
  type        = string
  description = "Azure DevOps Service URL where the repo should be created"
}

variable "devops_project_name" {
  description = "Name of the project on Azure DevOps"
  type        = string
}

variable "devops_project_description" {
  description = "Optional description of the Azure DevOps project."
  type        = string
  default     = ""
}

variable "public_project" {
  description = "Is this a public project? Default: false"
  type        = bool
  default     = false
}

variable "repo_name" {
  description = "Name of the repository."
  type        = string
  default     = ""
}

variable "default_branch" {
  description = "Default branch for the Azure DevOps git repository (full ref, e.g. refs/heads/main)."
  type        = string
  default     = "refs/heads/main"
}

variable "resource_prefix" {
  description = "A resource type postfix is appended to the individual IaC resources. Used in the storage account name, so it must comply with Azure storage account naming rules."
  type        = string

  validation {
    condition     = length(var.resource_prefix) >= 3 && length(var.resource_prefix) <= 20 && can(regex("^[a-z0-9]+$", var.resource_prefix))
    error_message = "resource_prefix must be 3-20 characters long and contain only lowercase letters and digits (used in storage account name)."
  }
}

variable "iac_resources_sub" {
  description = "Subscription in which the IaC resources, e.g. TF State storage account, are deployed."
  type        = string
}

variable "iac_ressources_rg" {
  description = "Resource group in which the IaC resources, e.g. TF State storage account, are deployed."
  type        = string
}

variable "remove" {
  type        = bool
  default     = false
  description = "Option to remove everything. Required to avoid provider removed issues."
}

variable "create_service_principle_prod" {
  type        = bool
  default     = false
  description = "Create service principal and DevOps service connection for prod deployment."
}

variable "create_service_principle_test" {
  type        = bool
  default     = false
  description = "Create service principal and DevOps service connection for test deployment."
}

variable "deployment_prod_tenant_id" {
  type        = string
  default     = ""
  description = "TenantId to which the prod workload should be deployed to. If not set, current Tenant is used."
}

variable "deployment_test_tenant_id" {
  type        = string
  default     = ""
  description = "TenantId to which the test workload should be deployed to. If not set, current Tenant is used."
}

variable "deployment_prod_sub_id" {
  type        = string
  default     = ""
  description = "Subscription to which the prod workload should be deployed to."
}

variable "deployment_test_sub_id" {
  type        = string
  default     = ""
  description = "Subscription to which the test workload should be deployed to."
}

variable "deployment_role_definition_name" {
  type        = string
  default     = "Contributor"
  description = "Built-in or custom role assigned to the deployment managed identities on the target subscription. Default 'Contributor' is broad; consider a custom role with least privilege."
}

variable "create_prod_pipeline" {
  type        = bool
  default     = false
  description = "Create a pipeline for prod. Default: false"
}

variable "create_test_pipeline" {
  type        = bool
  default     = false
  description = "Create a pipeline for test. Default: false"
}

variable "agent_pool_name" {
  type        = string
  default     = "Azure Pipelines"
  description = "Azure DevOps agent pool used by the generated build definitions. Use the name of a self-hosted pool when running agents inside a VNet."
}

variable "account_replication_type" {
  type        = string
  default     = "ZRS"
  description = "Replication type of the Terraform state storage account. TF state is small, so ZRS is usually sufficient; use GRS only if cross-region redundancy is required."

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to Azure resources created by this module."
}

variable "network_default_action" {
  type        = string
  default     = "Allow"
  description = "Default action for the state storage account network rules. Set to 'Deny' when using self-hosted agents in a VNet and providing network_ip_rules or network_subnet_ids."

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "network_default_action must be either 'Allow' or 'Deny'."
  }
}

variable "network_bypass" {
  type        = set(string)
  default     = ["AzureServices", "Logging", "Metrics"]
  description = "Services that bypass the network rules on the state storage account. Valid values: AzureServices, Logging, Metrics, None."
}

variable "network_ip_rules" {
  type        = set(string)
  default     = []
  description = "Public IPs or CIDR ranges allowed to access the state storage account. Only effective with network_default_action = 'Deny'."
}

variable "network_subnet_ids" {
  type        = set(string)
  default     = []
  description = "Subnet IDs allowed to access the state storage account via service endpoints. Only effective with network_default_action = 'Deny'."
}
