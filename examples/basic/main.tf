provider "clevercloud" {
  # Or CLEVER_ORGANISATION environment variable
  organisation = "orga_00000000-0000-0000-0000-000000000000"
}

# Secrets come from the environment, never from tfvars or code:
#   export TF_VAR_github_token=github_pat_xxx
variable "github_token" {
  type      = string
  sensitive = true
}

module "github_runner" {
  source = "../../"

  name         = "my-repo-runner"
  github_url   = "https://github.com/my-org/my-repo"
  github_token = var.github_token

  runner_labels  = ["clever-cloud", "linux"]
  flavor         = "M"
  instance_count = 2
}

output "app_id" {
  value = module.github_runner.app_id
}
