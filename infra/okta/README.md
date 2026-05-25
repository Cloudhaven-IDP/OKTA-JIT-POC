# Okta stack

Manages Okta-as-code: groups, group rules, IDC SAML app + SCIM, sign-on policy.

## Apply

State bucket comes from bootstrap output, passed via `-backend-config`:
```bash
STATE_BUCKET=$(jq -r .state_bucket_name.value ../../bootstrap-outputs.json)
terraform init -backend-config="bucket=$STATE_BUCKET"
terraform apply -auto-approve
```

After apply, paste `terraform output -raw aws_idc_app_metadata_url` into the AWS console: IAM Identity Center → Settings → Identity source → External identity provider.

## Destroy

```bash
./cleanup.sh
```
