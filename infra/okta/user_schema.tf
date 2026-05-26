resource "okta_user_schema_property" "subteam" {
  index       = "subteam"
  title       = "Subteam"
  type        = "string"
  master      = "OKTA"
  scope       = "NONE"
  user_type   = "default"
  permissions = "READ_WRITE"
}
