resource "okta_app_saml" "aws_idc" {
  label             = "AWS IAM Identity Center (JIT POC)"
  preconfigured_app = "amazon_aws"

  attribute_statements {
    type         = "GROUP"
    name         = "groups"
    filter_type  = "REGEX"
    filter_value = "(jit-requesters|team-.*)"
  }
}

resource "okta_app_group_assignment" "jit_requesters_to_aws_idc" {
  app_id   = okta_app_saml.aws_idc.id
  group_id = okta_group.this["jit-requesters"].id
}
