variable "org_service_url" {
  type        = string
  description = "Azure DevOps Service URL where the repo should be created"
}

variable "devops_project_name" {
  description = <<EOF
    Name of the project on Azure DevOps
  EOF
  type        = string
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

variable "resource_prefix" {
  description = "A resource type postfix is appended to the individual iac ressources."
  type        = string
}

variable "iac_resources_sub" {
  description = "Subscription in which the IaC ressources, e.g. TF State storage account, are deployed"
  type        = string
}

variable "iac_ressources_rg" {
  description = "RG in which the IaC ressources, e.g. TF State storage account, are deployed"
  type        = string
}

variable "remove" {
  type = bool
  default = false
  description = "Option to remove everything. Required to avoid provider removed issues."
}

variable "create_service_principle_prod" {
  type = bool
  default = false
  description = "Create service principle DevOps service connection for prod deployment"
}

variable "create_service_principle_test" {
  type = bool
  default = false
  description = "Create service principle and DevOps service connection for test deployment"
}

variable "service_principle_owner_prod" {
  type        = string
  description = "Email of the owner of the prod service principle"
  default = ""
}

variable "service_principle_owner_test" {
  type        = string
  description = "Email of the owner of the test service principle"
  default = ""
}

variable "deployment_prod_tenant_id" {
  type =  string
  default = ""
  description = "TenantId to which the prod workload should be deployed to. If not set, current Tenant is used."
}

variable "deployment_test_tenant_id" {
  type =  string
  default = ""
  description = "TenantId to which the test workload should be deployed to. If not set, current Tenant is used."
}

variable "deployment_prod_sub_id" {
  type =  string
  default = ""
  description = "Subscription to which the prod workload should be deployed to."
}

variable "deployment_test_sub_id" {
  type =  string
  default = ""
  description = "Subscription to which the test workload should be deployed to."
}