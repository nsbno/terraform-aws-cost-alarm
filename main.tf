provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}

locals {
  current_account_id = data.aws_caller_identity.this.account_id
}


###################################################
#                                                 #
# Account Budget                                  #
#                                                 #
###################################################
resource "aws_budgets_budget" "this" {
  name              = "${var.tags["environment"]}-${var.name_prefix}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.account_budget_limit_in_usd
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.budgetalarms.arn]
    subscriber_email_addresses = var.notification_emails
  }
}

resource "aws_sns_topic" "budgetalarms" {
  provider = aws.us-east-1
  name = "${var.tags["environment"]}-${var.name_prefix}-monthly-budget"
  tags = var.tags
}

resource "aws_sns_topic_policy" "budgetalarms_budgets" {
  arn    = aws_sns_topic.budgetalarms.arn
  policy = data.aws_iam_policy_document.sns.json
}

resource "aws_sns_topic_subscription" "budgetalarms_to_pagerduty" {
  endpoint               = "https://events.pagerduty.com/integration/7b03ab3499434e0fc08abdf0b81f68e1/enqueue"
  protocol               = "https"
  endpoint_auto_confirms = true
  topic_arn              = aws_sns_topic.budgetalarms.arn
}
