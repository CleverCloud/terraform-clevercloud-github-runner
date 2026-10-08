# Terraform CleverCloud GitHub Runner Module

Terraform module to run self-hosted [GitHub Actions runners](https://docs.github.com/en/actions/hosting-your-own-runners) on a CleverCloud [Linux](https://www.clever-cloud.com/developers/doc/applications/linux/) application.

## Features

- 🏃 Self-hosted GitHub Actions runner on the CleverCloud Linux runtime
- 🏢 Repository or organization runners, github.com or GitHub Enterprise Server
- 🔑 Registration through a GitHub token (recommended) or a one-shot registration token
- 🔒 Pinned runner version with SHA-256 check at build time
- 📈 One runner per instance, scale with `instance_count`
- 🧹 Runner unregisters itself when the instance stops

## How it works

The module creates a `clevercloud_linux` application and deploys this repository on it:

- **build** (`runner/build.sh`): downloads `actions/runner` (`runner_version`) and checks its SHA-256 (`runner_sha256`);
- **run** (`runner/start.sh`): gets a registration token, registers the runner as `<name>-<INSTANCE_NUMBER>` (with `--replace`, so redeploys reuse the same name), starts it, and answers the platform health check on `0.0.0.0:8080`. On `SIGTERM` the runner unregisters itself.

By default the application deploys the `main` branch of this repository, not the module version you pinned: set `commit` to a commit of the release to freeze the runner scripts too.

## Usage

### Basic Example

```hcl
module "github_runner" {
  source = "CleverCloud/github-runner/clevercloud"

  github_url   = "https://github.com/my-org/my-repo" # or https://github.com/my-org
  github_token = var.github_token
}
```

### Advanced Example

```hcl
module "github_runner" {
  source = "CleverCloud/github-runner/clevercloud"

  name         = "my-org-runners"
  region       = "par"
  github_url   = "https://github.com/my-org"
  github_token = var.github_token

  runner_labels = ["clever-cloud", "linux"]
  runner_group  = "clever-cloud"

  flavor         = "M"
  instance_count = 3
}
```

Workflows target the runner with `runs-on: self-hosted` (or any of `runner_labels`):

```yaml
jobs:
  build:
    runs-on: [self-hosted, clever-cloud]
```

## Secrets

Secrets only travel through environment variables: export them as `TF_VAR_*` before running Terraform (never in `.tfvars` or code), the module injects them as environment variables of the CleverCloud application.

```sh
export TF_VAR_github_token=github_pat_xxx   # recommended
# or, for a quick test:
export TF_VAR_runner_token=AXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Two ways to authenticate:

- **`github_token`** (recommended): the runner requests its own registration token at each boot, and unregisters itself on stop.
- **`runner_token`**: the token shown on GitHub's *Settings → Actions → Runners → New self-hosted runner* page. It expires after **1 hour**: a redeploy or a new instance after that fails to register, and the runner can't unregister itself.

`github_token` must be able to create runner registration tokens:

| Scope        | Fine-grained token permission     | Classic token |
| ------------ | --------------------------------- | ------------- |
| Repository   | Administration: read & write      | `repo`        |
| Organization | Self-hosted runners: read & write | `admin:org`   |

`GITHUB_TOKEN` and `RUNNER_TOKEN` are removed from the environment of the jobs, but they remain in the application environment: any workflow running on the runner can still read them. Don't use these runners for public repositories or pull requests from forks.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| clevercloud | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| clevercloud | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| github_url | Repository (`https://github.com/owner/repo`) or organization (`https://github.com/org`) URL the runner registers to | `string` | n/a | yes |
| github_token | GitHub token allowed to create runner registration tokens | `string` | `null` | no* |
| runner_token | Registration token from the GitHub "New self-hosted runner" page (expires after 1 hour) | `string` | `null` | no* |
| name | Name of the CleverCloud application, also the runner name prefix | `string` | `"github-runner"` | no |
| region | CleverCloud region (par, rbx, mtl, …) | `string` | `"par"` | no |
| runner_labels | Extra labels attached to the runner | `list(string)` | `["clever-cloud"]` | no |
| runner_group | Runner group (organization runners only) | `string` | `null` | no |
| runner_version | actions/runner version to install, or `latest` | `string` | `"2.337.0"` | no |
| runner_sha256 | SHA-256 of the runner tarball, checked when set | `string` | 2.337.0 linux-x64 hash | no |
| flavor | Instance flavor (XS, S, M, L, XL, …) | `string` | `"S"` | no |
| instance_count | Number of instances, each one registers its own runner | `number` | `1` | no |
| repository | Git repository deployed on the application, it must contain the `runner/` scripts | `string` | this repository | no |
| commit | Commit or ref of the repository to deploy (e.g. `refs/heads/main`) | `string` | `null` (HEAD) | no |
| environment | Extra environment variables injected into the application | `map(string)` | `{}` | no |

\* One of `github_token` or `runner_token` is required.

## Outputs

| Name | Description |
|------|-------------|
| app_id | ID of the CleverCloud application hosting the runner |
| runner_name | Runner name prefix, each instance registers as `<name>-<instance number>` |

## Environment variables

The module sets these environment variables on the application, read by the `runner/` scripts:

| Variable         | Source           |
| ---------------- | ---------------- |
| `GITHUB_URL`     | `github_url`     |
| `GITHUB_TOKEN`   | `github_token`   |
| `RUNNER_TOKEN`   | `runner_token`   |
| `RUNNER_NAME`    | `name`           |
| `RUNNER_LABELS`  | `runner_labels`  |
| `RUNNER_GROUP`   | `runner_group`   |
| `RUNNER_VERSION` | `runner_version` |
| `RUNNER_SHA256`  | `runner_sha256`  |

Anything in `environment` is added too (module variables win on conflict).

## Examples

- [basic](examples/basic): repository runner with a GitHub token
- [test](examples/test): throwaway runner deployed from the local checkout

## License

MIT
