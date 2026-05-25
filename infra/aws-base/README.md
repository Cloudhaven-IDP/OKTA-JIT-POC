# aws-base stack

Truly shared resources — anything both apps depend on.

## What it creates

- **IDC `TF-AWS-JIT-Requesters`** permission set, assigned to the Okta `jit-requesters` group.
- **`jit-grants`** DynamoDB table (PITR on, GSI `user_email_index`, no TTL).
- **S3 target** bucket + demo files, tagged `JIT = "true"`.
- **`prod/my-very-sensitive-secret`** Secrets Manager target, tagged `JIT = "true"`.

App stacks (`aws-app/janitor`, `aws-app/jit-frontend`) discover JIT targets at runtime via tag-based queries (ABAC).

## Apply

```bash
STATE_BUCKET=$(jq -r .state_bucket_name.value ../../bootstrap-outputs.json)
terraform init -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
```

## Destroy

Use the repo-root `cleanup.sh`.
