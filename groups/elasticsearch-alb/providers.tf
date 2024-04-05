provider "aws" {
  region = var.region
}

provider "aws" {
  alias   = "development_eu_west_1"
  region  = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.account_ids.development}:role/${data.aws_caller_identity.current.account_id}-terraform-lookup"
  }
}
