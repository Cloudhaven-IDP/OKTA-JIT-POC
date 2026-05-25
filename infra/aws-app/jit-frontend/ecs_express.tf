locals {
  principal_pattern_template = "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSReservedSSO_TF-AWS-JIT-Requesters_*/{email}"

  container_env = [
    { name = "GRANTS_TABLE_NAME", value = data.aws_dynamodb_table.grants.name },
    { name = "JANITOR_LAMBDA_ARN", value = data.aws_lambda_function.janitor.arn },
    { name = "JANITOR_INVOCATION_ROLE_ARN", value = data.aws_iam_role.janitor_invocation.arn },
    { name = "SCHEDULER_GROUP", value = "jit-grants" },
    { name = "OKTA_SECRET_NAME", value = data.aws_secretsmanager_secret.okta_token.name },
    { name = "AWS_ACCOUNT_ID", value = data.aws_caller_identity.current.account_id },
    { name = "PRINCIPAL_PATTERN_TEMPLATE", value = local.principal_pattern_template },
    { name = "TEST_USERS", value = data.aws_ssm_parameter.reviewer_email.value },
    { name = "USE_OKTA_SSO", value = "false" },
  ]
}

module "streamlit_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/express-service"
  version = "~> 7.4"

  name = "jit-streamlit"

  primary_container = {
    image          = "${module.streamlit_ecr.repository_url}:${data.aws_ssm_parameter.image_tag.value}"
    container_port = 8080
    environment    = local.container_env
  }

  task_iam_role_arn = module.ecs_task_role.role_arn

  runtime_platform = {
    cpu_architecture = "ARM64"
  }
}
