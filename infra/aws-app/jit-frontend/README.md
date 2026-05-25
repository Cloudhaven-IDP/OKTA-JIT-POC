# aws-app/jit-frontend stack

The Streamlit JIT portal.

## Owns

- `jit-streamlit` ECR repo
- `jit-ecs-task` IAM role (Streamlit's runtime role; DDB writes, ABAC-gated target policy admin, scheduler CRUD, iam:PassRole on janitor invocation role, Okta secret read, ResourceGroupsTaggingAPI read).
- `jit-streamlit` ECS Express Mode service (arm64, single container, public HTTPS URL via `*.ecs.<region>.on.aws`).
- `/jit/jit-frontend/image_tag` SSM param.

## Reads

Direct AWS data sources (no SSM intermediary): `data "aws_dynamodb_table"`, `data "aws_lambda_function"`, `data "aws_iam_role"`, `data "aws_secretsmanager_secret"`. Plus `/jit/setup/reviewer_email` and `/jit/jit-frontend/image_tag` SSM params.

Targets are discovered by Streamlit at runtime via ResourceGroupsTaggingAPI on `JIT=true`.

## Apply

```bash
STATE_BUCKET=$(jq -r .state_bucket_name.value ../../../bootstrap-outputs.json)
terraform init -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
```

Apply order: `okta → aws-base → janitor → jit-frontend`.

## Destroy

Use the repo-root `cleanup.sh`.
