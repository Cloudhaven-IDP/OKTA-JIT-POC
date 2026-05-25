module "jit_requesters_permission_set" {
  source = "../modules/aws/iam/permission-set"

  permission_set_name = "TF-AWS-JIT-Requesters"
  description         = "Minimal AWS access. Resource-level access is granted JIT via target resource policies."
  session_duration    = "PT1H"
  inline_policy       = data.aws_iam_policy_document.jit_requesters_inline.json
  group_names         = ["jit-requesters"]
  account_ids         = [data.aws_caller_identity.current.account_id]
}
