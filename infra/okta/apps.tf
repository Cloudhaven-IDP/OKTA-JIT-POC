resource "okta_app_bookmark" "aws_access_portal" {
  label = "AWS Access Portal"
  url   = "https://d-90660ebbc1.awsapps.com/start"
}

resource "okta_app_group_assignment" "jit_requesters_to_aws" {
  app_id   = okta_app_bookmark.aws_access_portal.id
  group_id = okta_group.this["jit-requesters"].id
}
