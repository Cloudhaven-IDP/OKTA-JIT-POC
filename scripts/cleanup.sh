#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
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
  terraform destroy -auto-approve "$@"
  popd >/dev/null
}

# Reverse apply order. aws-app sub-stacks first (depend on aws-base), then aws-base, then okta.
destroy_stack "aws-app/jit-frontend"
destroy_stack "aws-app/janitor" -var "github_repo=placeholder/placeholder"
destroy_stack "aws-base"
destroy_stack "okta"

# Bootstrap is local-state and has unique teardown logic (state file removal).
echo ""
infra/bootstrap/cleanup.sh

echo ""
echo "✓ Cleanup complete."
