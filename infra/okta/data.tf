data "aws_secretsmanager_secret_version" "okta" {
  secret_id = "/jit/okta/api-token"
}

data "aws_ssm_parameter" "reviewer_email" {
  name = "/jit/setup/reviewer_email"
}

locals {
  okta           = jsondecode(data.aws_secretsmanager_secret_version.okta.secret_string)
  reviewer_email = data.aws_ssm_parameter.reviewer_email.value
}
