resource "azuredevops_project" "myproject" {
  name               = var.project_name
  visibility         = vat.public_project ? "public" : "private"
  version_control    = "Git"
  work_item_template = ""
}

resource "azuredevops_git_repository" "myrepo" {
  project_id = azuredevops_project.myproject.id
  name       = var.repo_name
  initialization {
    init_type = "Clean"
  }
}