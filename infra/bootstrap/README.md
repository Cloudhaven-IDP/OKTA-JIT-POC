# Bootstrap

Local-state stack run once with admin credentials. Creates the things every other stack assumes exist.

**Why local state:** this stack *creates* the S3 + DynamoDB backend that all other stacks use. It can't store state in a backend that doesn't exist yet. After bootstrap, `terraform.tfstate` lives here in this directory.

## What it creates

| Resource | Purpose |
|---|---|
| `jit-tfstate-<random>` (S3) | Terraform state bucket for all other stacks |
| `jit-tfstate-lock` (DynamoDB) | State locking |
| GitHub OIDC provider | Federation for CI/CD |
| `jit-tf-plan` role | Read-only; assumed by PR plan jobs from any branch |
| `aws_deployer` role | Write; assumed by main-branch apply + image push + SSM updates |
| `/jit/okta/api-token` (Secrets Manager) | Okta provider auth for subsequent stacks |

## Apply

Driven by `../../setup.sh` (which prompts for the inputs). Direct apply:

```bash
terraform init
terraform apply \
  -var "github_repo=owner/repo" \
  -var "okta_org_url=https://integrator-XXXX.okta.com" \
  -var "okta_api_token=…"
```

## Destroy

Use `./cleanup.sh` (also called by the repo-root `cleanup.sh`). It runs `terraform destroy`, then removes the local state files so the directory can be re-initialized cleanly.
