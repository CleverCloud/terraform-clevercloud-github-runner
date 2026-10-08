locals {
  runner_environment = { for k, v in {
    GITHUB_URL     = var.github_url
    GITHUB_TOKEN   = var.github_token
    RUNNER_TOKEN   = var.runner_token
    RUNNER_NAME    = var.name
    RUNNER_LABELS  = join(",", var.runner_labels)
    RUNNER_GROUP   = var.runner_group
    RUNNER_VERSION = var.runner_version
    RUNNER_SHA256  = var.runner_sha256
  } : k => v if v != null }
}

resource "clevercloud_linux" "runner" {
  name               = var.name
  region             = var.region
  smallest_flavor    = var.flavor
  biggest_flavor     = var.flavor
  min_instance_count = var.instance_count
  max_instance_count = var.instance_count

  build_command = "./runner/build.sh"
  run_command   = "./runner/start.sh"

  environment = merge(var.environment, local.runner_environment)

  deployment {
    repository = coalesce(var.repository, "file://${abspath(path.module)}")
    commit     = var.commit
  }

  lifecycle {
    precondition {
      condition     = var.github_token != null || var.runner_token != null
      error_message = "Set github_token (recommended) or runner_token."
    }
  }
}
