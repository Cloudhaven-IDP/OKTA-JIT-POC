module "janitor_ecr" {
  source          = "../../modules/aws/ecr"
  repository_name = "jit-janitor"
}
