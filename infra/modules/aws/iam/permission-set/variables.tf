variable "group_names" {
  type        = list(string)
  description = "List of IAM Identity Center group names"
}

variable "group_memberships" {
  type        = map(list(string))
  description = <<EOT
  A map of group names to lists of user names to assign.
  Example: {
    "Cloudhaven-Admins" = ["bazit"]
  }
  EOT
  default     = {}
}

variable "permission_set_name" {
  type        = string
  description = "Name of the permission set"
}

variable "description" {
  type    = string
  default = ""
}

variable "session_duration" {
  type    = string
  default = "PT1H"
}

variable "relay_state" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "account_ids" {
  type        = list(string)
  description = "AWS account IDs to assign group"
}

variable "aws_managed_policies" {
  type    = list(string)
  default = []
}

variable "customer_managed_policies" {
  type    = list(string)
  default = []

  validation {
    condition     = alltrue([for p in var.customer_managed_policies : can(regex("[\\w+=,.@-]+", p))])
    error_message = "Customer managed policy names must be valid"
  }
}

variable "access_restricted_ssm" {
  type    = bool
  default = false
}

variable "inline_policy" {
  type    = string
  default = null
}