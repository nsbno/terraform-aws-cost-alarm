data "aws_default_tags" "tags" {}

module "budget" {
  source                      = "github.com/nsbno/terraform-aws-cost-alarm?ref=3a8a43e"  
  name_prefix                 = var.name_prefix
  notification_emails         = ["teamemail@vy.no"]
  account_budget_limit_in_usd = var.account_budget_limit_in_usd
  env                         = data.aws_default_tags.tags.tags.env
}