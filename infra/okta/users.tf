resource "okta_user" "reviewer" {
  email      = local.reviewer_email
  login      = local.reviewer_email
  first_name = split("@", local.reviewer_email)[0]
  last_name  = "Reviewer"
  department = "engineering"
  custom_profile_attributes = jsonencode({
    subteam = "developers"
  })

  depends_on = [okta_user_schema_property.subteam]
}
