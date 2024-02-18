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