# terraform-github-runner

Self-hosted GitHub Actions runner on a Clever Cloud [Linux](https://www.clever-cloud.com/developers/doc/applications/linux/) application.

The module creates a `clevercloud_linux` app and deploys this repository on it:

- **build** (`runner/build.sh`): downloads `actions/runner` (`runner_version`, 2.337.0 by default) and checks its SHA-256 (`runner_sha256`);
- **run** (`runner/start.sh`): requests a registration token from the GitHub API, registers the runner as `<name>-<INSTANCE_NUMBER>` (with `--replace`, so redeploys reuse the same name), starts it, and answers the platform health check on `0.0.0.0:8080`. On `SIGTERM` the runner unregisters itself.

Each instance is one runner: scale with `instance_count`.

## Usage

```hcl
module "github_runner" {
  source = "github.com/<org>/terraform-github-runner"

  github_url   = "https://github.com/my-org/my-repo" # or https://github.com/my-org
  github_token = var.github_token
}
```

## Secrets

Secrets only travel through environment variables: export them as `TF_VAR_*` before running Terraform (never in `.tfvars` or code), the module injects them as environment variables of the Clever Cloud app.

```sh
export TF_VAR_github_token=github_pat_xxx   # recommended
# or, for a quick test:
export TF_VAR_runner_token=AXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Two ways to authenticate:

- **`github_token`** (recommended): the runner requests its own registration token at each boot, and unregisters itself on stop.
- **`runner_token`**: the token shown on GitHub's *Settings → Actions → Runners → New self-hosted runner* page (`./config.sh --token ...`). It expires after **1 hour**: a redeploy or a new instance after that fails to register, and the runner can't unregister itself.

`github_token` must be able to create runner registration tokens:

| Scope        | Fine-grained token permission           | Classic token |
| ------------ | --------------------------------------- | ------------- |
| Repository   | Administration: read & write            | `repo`        |
| Organization | Self-hosted runners: read & write       | `admin:org`   |

## Deployed code

By default the app is deployed from this module's own git checkout (`file://<module path>`, HEAD commit), so the module directory must be a git repository with the `runner/` scripts committed. Set `repository` (and optionally `commit`) to deploy from a remote instead.

## Environment variables

| Variable         | Source                      |
| ---------------- | --------------------------- |
| `GITHUB_URL`     | `github_url`                |
| `GITHUB_TOKEN`   | `github_token`              |
| `RUNNER_TOKEN`   | `runner_token`              |
| `RUNNER_NAME`    | `name`                      |
| `RUNNER_LABELS`  | `runner_labels` (joined)    |
| `RUNNER_GROUP`   | `runner_group`              |
| `RUNNER_VERSION` | `runner_version`            |
| `RUNNER_SHA256`  | `runner_sha256`             |

Anything in `environment` is added too (module variables win on conflict). `GITHUB_TOKEN` and `RUNNER_TOKEN` are removed from the environment of the jobs run by the runner.

Workflows target the runner with `runs-on: self-hosted` (or any of `runner_labels`).
