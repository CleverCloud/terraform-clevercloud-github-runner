# Test Example

Throwaway runner deployed from the local checkout (`file://`, committed HEAD), to test changes of the `runner/` scripts before pushing them.

```sh
git commit -am "wip"   # the committed HEAD is deployed
export CC_ORGANISATION=orga_xxx
export TF_VAR_runner_token=...   # GitHub → Settings → Actions → Runners → New self-hosted runner
terraform init
terraform apply
clever logs --app "$(terraform output -raw app_id)"
```

Clean up with `terraform destroy`, then remove the runner on GitHub: a runner registered with `runner_token` can't unregister itself.
