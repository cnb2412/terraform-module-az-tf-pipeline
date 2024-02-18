resource "azuredevops_project" "myproject" {
  name               = var.project_name
  visibility         = var.public_project ? "public" : "private"
  version_control    = "Git"
  work_item_template = ""
}

locals {
  repo_name = length(var.repo_name) > 0 ? var.repo_name : "${var.project_name}_repo"
}
resource "azuredevops_git_repository" "myrepo" {
  project_id = azuredevops_project.myproject.id
  name       = local.repo_name
  initialization {
    init_type = "Clean"
  }
}