provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}

locals {
  current_account_id = data.aws_caller_identity.this.account_id
}



