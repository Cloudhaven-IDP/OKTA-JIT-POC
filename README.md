# JIT-as-a-Pipeline

A workflow for granting least-privilege access on demand. Engineers request the
permissions they need for a specific job, access is scoped to that job, and it's
revoked just in time. No operator sits in the middle approving tickets.

Say a BI teammember needs to pull some objects from S3, a backend dev needs to drain
a stuck SQS queue, or an engineer needs to update a secret backing a production
service. They open the portal, ask for the access, get it for the window they
asked for, and the system pulls it back when the timer ends.

## What this is

A monorepo for the infrastructure and the application code that runs the POC.

## Quick start

You'll need locally: Terraform, AWS CLI, `jq`, `uv`, and `gh` (or a
`GITHUB_TOKEN` exported). On the AWS side: credentials with permission to
provision IAM, S3, DynamoDB, Secrets Manager, SSM, and IAM Identity Center;
IAM Identity Center enabled on the account; and a VPC in the working
region.

Validate all of that with the preflight check:

```bash
./scripts/check-prereqs.sh
```

When that passes, bootstrap the project:

```bash
./scripts/setup.sh
```

Setup prompts you for an email and name and writes them to
`infra/identity.yaml`. That file is the single source of truth for the user
identities the pipeline provisions into both Okta and AWS Identity Center, so
running setup is what gives you someone to log in as on the other side. Skip
it and there is no portal user, no IDC user, nothing to assume the permission
set.

Setup then applies the bootstrap stack: an S3 state bucket, a DynamoDB lock
table, and the GitHub OIDC roles. That's the only stack the user applies
locally. It's a singleton, and it has to exist before anything downstream can
read state or assume a deployer role. Every other stack is applied by the
`infra-apply` GitHub Actions workflow under the OIDC role, not by the user.

The project runs on any Okta tenant and any AWS account, but the safer setup is
a developer or integrator tenant from [developer.okta.com](https://developer.okta.com)
and a sandbox or fresh AWS account. This POC touches IAM and IAM Identity
Center, neither of which you want tangled up with production.

Teardown is split the same way: the `infra-destroy` workflow tears the
stacks down under the OIDC role, then `infra/bootstrap/cleanup.sh` runs
locally to remove the state bucket and its supporting resources. The
walkthrough is in [`infra/README.md`](infra/README.md#how-teardown-happens).

## How JIT works

A user opens the portal, picks the resource they need access to, picks the
actions, picks a duration, and writes a justification. If the request clears
the checks, they get scoped access for that window. When the window closes,
access is revoked.

Okta is the identity provider. The POC ships with two resource types, S3
buckets and Secrets Manager secrets, and the same shape extends to anything
else that supports a resource policy.

## Repo map

```
infra/              Terraform stacks and Okta-as-code
app/                Streamlit portal and Janitor Lambda
scripts/            bootstrap, teardown, and quality-of-life scripts
.github/workflows/  CI/CD pipeline
documentation/      overview, deployment-and-teardown, and quirks
```

## What's missing (and what's next)

This is a POC. SCIM provisioning, SAML federation between Okta and AWS Identity
Center, app-level SSO, cross-team authorization, multi-account promotion, and a
runtime policy layer aren't here yet. Without SCIM and SAML, you'll have to
click through both the AWS Identity Center invitation email and the Okta
invitation email by hand after bootstrap before you can log into the portal.

Architecture, decisions, and the deployment walkthrough live in
`documentation/`.
