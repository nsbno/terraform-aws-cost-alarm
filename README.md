# terraform-aws-cost-alarm

Module for setting a cost alarm based on forecasted budget and integrating it with a central pagerduty alarm

Example:

module "budget" {
  source = "github.com/nsbno/terraform-aws-cost-alarm?ref=3a8a43e"
  name_prefix = var.name_prefix
  env         = var.environment
  notification_emails = ["teamemail@vy.no"]
  account_budget_limit_in_usd = var.account_budget_limit_in_usd
}
