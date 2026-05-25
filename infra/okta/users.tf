resource "okta_user" "reviewer" {
  email      = local.reviewer_email
  login      = local.reviewer_email
  first_name = split("@", local.reviewer_email)[0]
  last_name  = "Reviewer"
  custom_profile_attributes = jsonencode({
    department = "engineering"
    subteam    = "developers"
  })
}
