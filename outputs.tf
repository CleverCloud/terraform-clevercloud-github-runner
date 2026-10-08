output "app_id" {
  description = "ID of the Clever Cloud application hosting the runner"
  value       = clevercloud_linux.runner.id
}

output "runner_name" {
  description = "Runner name prefix, each instance registers as <name>-<instance number>"
  value       = var.name
}
