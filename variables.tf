variable "project_name" {
  description = <<EOF
    Name of the project on Azure DevOps
  EOF
  type        = string
}

variable "public_project" {
  description = "Is this a public project? Default: false"
  type        = bool
  default = false
}

variable "repo_name" {
  description = "Name of the repository."
  type        = string
  default = ""
}