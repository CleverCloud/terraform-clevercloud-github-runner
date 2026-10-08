# Basic Example

Repository runner registered with a GitHub token.

```sh
export CC_ORGANISATION=orga_xxx
export TF_VAR_github_token=github_pat_xxx
terraform init
terraform apply
```

The token needs the *Administration: read & write* permission on the repository (fine-grained) or the `repo` scope (classic).
