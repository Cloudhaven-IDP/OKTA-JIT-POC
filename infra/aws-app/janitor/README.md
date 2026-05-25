# aws-app/janitor stack

The Janitor Lambda + scheduler group + supporting IAM and ECR.

## Owns

- `jit-janitor` ECR repo
- `jit-janitor` Lambda (arm64, image-based). Placeholder image at create; app-ci updates via `aws lambda update-function-code`. The lambda module's `lifecycle.ignore_changes = [image_uri]` keeps TF out of the way.
- `jit-janitor-revoke` IAM policy (DDB get/update + ABAC-gated target resource-policy mutation).
- `jit-scheduler-invoke-janitor` IAM role assumed by EventBridge Scheduler.
- `jit-grants` Scheduler group (per-grant schedules created at runtime by the Streamlit app).
- `/jit/janitor/image_tag` SSM param (record of the current image tag, written by app-ci).

## Apply

```bash
STATE_BUCKET=$(jq -r .state_bucket_name.value ../../../bootstrap-outputs.json)
terraform init -backend-config="bucket=$STATE_BUCKET"
terraform apply -var "github_repo=owner/repo" -auto-approve
```

## Destroy

Use the repo-root `cleanup.sh`.
