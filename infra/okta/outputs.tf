output "aws_idc_app_metadata_url" {
  value       = okta_app_saml.aws_idc.metadata_url
  description = "Paste this into AWS IDC's External IdP SAML configuration."
}
