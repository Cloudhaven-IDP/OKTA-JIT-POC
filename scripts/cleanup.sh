#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STATE_BUCKET=$(jq -r .state_bucket_name.value bootstrap-outputs.json 2>/dev/null || true)
if [ -z "$STATE_BUCKET" ]; then
  read -rp "TF state bucket name: " STATE_BUCKET
fi

destroy_stack() {
  local stack="$1"
  shift
  echo ""
  echo "==> Destroying $stack"
  pushd "infra/$stack" >/dev/null
  terraform init -reconfigure -backend-config="bucket=$STATE_BUCKET" >/dev/null
  local attempt=1
  until terraform destroy -auto-approve "$@"; do
    if [ "$attempt" -ge 3 ]; then
      popd >/dev/null
      return 1
    fi
    echo "  destroy attempt $attempt failed; retrying in 5s..."
    sleep 5
    attempt=$((attempt+1))
  done
  popd >/dev/null
}

empty_ecr_repo() {
  local repo="$1"
  local imgs
  imgs=$(aws ecr list-images --repository-name "$repo" --region us-east-1 --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
  [ "$imgs" = "[]" ] && return 0
  aws ecr batch-delete-image --repository-name "$repo" --region us-east-1 --image-ids "$imgs" >/dev/null
}

scale_down_streamlit() {
  aws ecs update-service --cluster default --service jit-frontend \
    --desired-count 0 --region us-east-1 >/dev/null 2>&1 || true
  aws ecs wait services-stable --cluster default --services jit-frontend \
    --region us-east-1 2>/dev/null || true
}


# If the TF state bucket is gone, the remote-state stacks are already torn down.
if ! aws s3api head-bucket --bucket "$STATE_BUCKET" >/dev/null 2>&1; then
  echo "State bucket $STATE_BUCKET not found — stacks may already have been cleaned up. Skipping to bootstrap teardown."
else
  scale_down_streamlit
  destroy_stack "aws-app/jit-frontend"
  destroy_stack "aws-app/janitor" -var "github_repo=placeholder/placeholder"
  empty_ecr_repo jit-streamlit
  empty_ecr_repo jit-janitor
  destroy_stack "aws-base"
  destroy_stack "okta"
fi

# Bootstrap is local-state and has unique teardown logic (state file removal).
echo ""
infra/bootstrap/cleanup.sh

# Drop the cached bootstrap outputs — leaving it would point the next cleanup
# (or any state-bucket-aware script) at a deleted bucket.
rm -f "$ROOT/bootstrap-outputs.json"

echo ""
echo "✓ Cleanup complete."
