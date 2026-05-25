#!/usr/bin/env bash
# Per-stack teardown. Called by the repo-root cleanup.sh, but also runnable on its own.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Bootstrap cleanup"

if [ ! -f "terraform.tfstate" ] && [ ! -d ".terraform" ]; then
  echo "    No local state found. Nothing to destroy."
else
  # Required variables must be passed even for destroy; the values aren't used,
  # but Terraform validates them. Use harmless placeholders.
  terraform destroy -auto-approve \
    -var "github_repo=placeholder/placeholder" \
    -var "okta_org_url=https://placeholder.okta.com" \
    -var "okta_api_token=placeholder"
fi

echo "    Removing local state + .terraform/"
rm -rf terraform.tfstate terraform.tfstate.backup .terraform .terraform.lock.hcl

echo "✓ Bootstrap directory clean."
