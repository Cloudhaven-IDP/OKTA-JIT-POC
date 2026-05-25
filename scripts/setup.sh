#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

./scripts/check-prereqs.sh

read -rp "GitHub repo (owner/repo): " GITHUB_REPO
echo "    Okta tenant URL — e.g., https://integrator-5647961.okta.com (NOT the -admin URL)"
read -rp "Okta org URL: " OKTA_ORG
read -rsp "Okta API token: " OKTA_TOKEN; echo
echo "    Your email (seeded as Okta user; populates the Streamlit TEST_USERS dropdown)"
read -rp "Your email: " REVIEWER_EMAIL
echo "    GitHub PAT (scopes: repo, admin:repo_hook). ENTER to skip if GITHUB_TOKEN is set."
read -rsp "GitHub token: " GITHUB_PAT; echo
if [ -n "$GITHUB_PAT" ]; then
  export GITHUB_TOKEN="$GITHUB_PAT"
fi

pushd infra/bootstrap >/dev/null
terraform init -upgrade
terraform apply -auto-approve \
  -var "github_repo=$GITHUB_REPO" \
  -var "okta_org_url=$OKTA_ORG" \
  -var "okta_api_token=$OKTA_TOKEN"
terraform output -json > "$ROOT/bootstrap-outputs.json"
STATE_BUCKET=$(terraform output -raw state_bucket_name)
popd >/dev/null

# Persist reviewer_email so subsequent applies (and workflow_dispatch from CI) can read it.
aws ssm put-parameter \
  --name /jit/setup/reviewer_email \
  --value "$REVIEWER_EMAIL" \
  --type String --overwrite >/dev/null

pushd infra/okta >/dev/null
terraform init -upgrade -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
popd >/dev/null

pushd infra/aws-base >/dev/null
terraform init -upgrade -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
popd >/dev/null

# aws-app stacks apply before app-ci so ECR repos exist. Lambda uses a public placeholder
# image; ECS Express won't pull cleanly until app-ci pushes a real Streamlit image.
pushd infra/aws-app/janitor >/dev/null
terraform init -upgrade -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve -var "github_repo=$GITHUB_REPO"
popd >/dev/null

pushd infra/aws-app/jit-frontend >/dev/null
terraform init -upgrade -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
popd >/dev/null

echo ""
echo "✓ Setup complete."
echo "  Push to '$GITHUB_REPO' main to trigger app-ci (builds + pushes images,"
echo "  updates the Janitor function, dispatches infra-apply for jit-frontend)."
echo ""
echo "  Streamlit URL (after app-ci finishes):"
echo "    cd infra/aws-app/jit-frontend && terraform init -backend-config=\"bucket=$STATE_BUCKET\" && terraform output -raw streamlit_url"
