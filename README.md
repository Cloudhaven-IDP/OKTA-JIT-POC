# JIT-on-a-Pipeline

CI/CD pipeline that manages an Okta tenant and an ECS server set, deploying a JIT-access workload as the thing it governs.

## Quick start
```bash
./scripts/check-prereqs.sh
./setup.sh                  # bootstrap + apply okta + apply aws-base
# git push origin main      # triggers app-ci → image push → aws-app apply
./cleanup.sh                # teardown
```

