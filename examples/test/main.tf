# Throwaway runner on CleverCloud/magnetar.
#   export CC_ORGANISATION=orga_xxx
#   export TF_VAR_runner_token=<token from the "New self-hosted runner" page>
terraform {
  required_providers {
    clevercloud = {
      source  = "CleverCloud/clevercloud"
      version = "~> 2.3"
    }
  }
}

provider "clevercloud" {}

variable "runner_token" {
  type      = string
  sensitive = true
}

module "github_runner" {
  source = "../../"

  name         = "magnetar-runner-test"
  github_url   = "https://github.com/CleverCloud/magnetar"
  runner_token = var.runner_token

  # Deploy the local checkout (committed HEAD) instead of GitHub
  repository = "file://${abspath("${path.root}/../..")}"

  runner_labels = ["clever-cloud", "test"]
  flavor        = "3XL"
}

output "app_id" {
  value = module.github_runner.app_id
}
