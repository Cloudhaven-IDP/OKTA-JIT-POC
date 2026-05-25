resource "aws_identitystore_group" "this" {
  for_each          = { for name in var.group_names : name => name }
  identity_store_id = local.identity_store_id
  display_name      = each.value
  description       = "Group for ${each.value}"
}

data "aws_identitystore_user" "this" {
  for_each = toset(flatten(values(var.group_memberships)))

  identity_store_id = local.identity_store_id
  user_name         = each.value
}

resource "aws_identitystore_user_group_membership" "this" {
  for_each = merge([
    for group_name, users in var.group_memberships : {
      for user in users :
      "${group_name}:${user}" => {
        group_name = group_name
        user_name  = user
      }
    }
  ]...)

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_name].group_id
  user_id           = data.aws_identitystore_user.this[each.value.user_name].user_id
}

resource "aws_ssoadmin_permission_set" "this" {
  name             = var.permission_set_name
  instance_arn     = local.instance_arn
  description      = var.description
  session_duration = var.session_duration
  relay_state      = var.relay_state
  tags             = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = toset(var.aws_managed_policies)

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  managed_policy_arn = each.value
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = toset(var.customer_managed_policies)

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = each.value
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  count = length(local.inline_policies) > 0 ? 1 : 0

  inline_policy      = data.aws_iam_policy_document.merged_inline[0].json
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

resource "aws_ssoadmin_account_assignment" "group_assignment" {
  for_each = { for group_name in var.group_names : group_name => group_name }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = aws_identitystore_group.this[each.value].group_id
  principal_type = "GROUP"

  target_id   = var.account_ids[0]
  target_type = "AWS_ACCOUNT"
}