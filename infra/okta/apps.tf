resource "okta_app_saml" "aws_idc" {
  label                    = "AWS IAM Identity Center (JIT POC)"
  preconfigured_app        = "amazon_aws"
  sso_url                  = "https://signin.aws.amazon.com/saml"
  recipient                = "https://signin.aws.amazon.com/saml"
  destination              = "https://signin.aws.amazon.com/saml"
  audience                 = "https://signin.aws.amazon.com/saml"
  subject_name_id_template = "$${user.userName}"
  subject_name_id_format   = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  response_signed          = true
  signature_algorithm      = "RSA_SHA256"
  digest_algorithm         = "SHA256"

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
