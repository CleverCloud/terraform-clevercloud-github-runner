variable "name" {
  description = "Name of the Clever Cloud application hosting the runner"
  type        = string
  default     = "github-runner"
}

variable "region" {
  description = "Clever Cloud region (e.g., par, rbx, mtl)"
  type        = string
  default     = "par"
}

variable "github_url" {
  description = "Repository (https://github.com/owner/repo) or organization (https://github.com/org) URL the runner registers to"
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+/[^/]+(/[^/]+)?/?$", var.github_url))
    error_message = "github_url must look like https://github.com/owner or https://github.com/owner/repo."
  }
}

variable "github_token" {
  description = "GitHub token allowed to create runner registration tokens (repo: 'Administration' write, org: 'Self-hosted runners' write). Pass it through TF_VAR_github_token"
  type        = string
  sensitive   = true
  default     = null
}

variable "runner_token" {
  description = "Registration token from the GitHub 'New self-hosted runner' page (expires after 1 hour), used when github_token is not set. Pass it through TF_VAR_runner_token"
  type        = string
  sensitive   = true
  default     = null
}

variable "runner_labels" {
  description = "Extra labels attached to the runner (self-hosted, Linux, X64 are added by GitHub)"
  type        = list(string)
  default     = ["clever-cloud"]
}

variable "runner_group" {
  description = "Runner group (organization runners only)"
  type        = string
  default     = null
}

variable "runner_version" {
  description = "actions/runner version to install (e.g., 2.337.0), or 'latest'"
  type        = string
  default     = "2.337.0"
}

variable "runner_sha256" {
  description = "SHA-256 of the runner tarball, checked at build time when set (default matches 2.337.0 linux-x64)"
  type        = string
  default     = "70920811a4f8ad4328818682bca5c6469c1c942fab52448868071d0063816613"
}

variable "flavor" {
  description = "Instance flavor (e.g., XS, S, M, L, XL)"
  type        = string
  default     = "S"
}

variable "instance_count" {
  description = "Number of instances, each one registers its own runner"
  type        = number
  default     = 1
}

variable "repository" {
  description = "Git repository deployed on the app, it must contain the runner/ scripts"
  type        = string
  default     = "https://github.com/CleverCloud/terraform-clevercloud-github-runner.git"
}

variable "commit" {
  description = "Commit/ref of the repository to deploy (e.g., refs/heads/main). Defaults to HEAD"
  type        = string
  default     = null
}

variable "environment" {
  description = "Extra environment variables injected into the runner app"
  type        = map(string)
  default     = {}
}
