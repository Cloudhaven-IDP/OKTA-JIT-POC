terraform {
  backend "s3" {
    key            = "okta/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jit-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      project = "jit-access-poc"
      stack   = "okta"
      team    = "platform"
    }
  }
}

provider "okta" {
  org_name  = replace(replace(local.okta.org_url, "https://", ""), ".okta.com", "")
  base_url  = "okta.com"
  api_token = local.okta.token
}
