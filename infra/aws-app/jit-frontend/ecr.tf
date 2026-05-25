module "streamlit_ecr" {
  source          = "../../modules/aws/ecr"
  repository_name = "jit-streamlit"
}
