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
  name              = "${var.env}-${var.name_prefix}-monthly-budget"
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
    subscriber_sns_topic_arns  = [aws_sns_topic.budget.arn]
    subscriber_email_addresses = setunion(var.notification_emails, ["aws-budget-alarms-email.obdw3nwx@vyutv.pagerduty.com"])
  }
}

resource "aws_sns_topic" "budget" {
  name = "${var.env}-${var.name_prefix}-monthly-budget"
}

resource "aws_sns_topic_policy" "allow_budgets" {
  arn    = aws_sns_topic.budget.arn
  policy = data.aws_iam_policy_document.sns.json
}

resource "aws_sns_topic_subscription" "alarms_to_pagerduty" {
  endpoint               = "https://events.pagerduty.com/integration/7b03ab3499434e0fc08abdf0b81f68e1/enqueue"
  protocol               = "https"
  endpoint_auto_confirms = true
  topic_arn              = aws_sns_topic.budget.arn
}

###################################################
#                                                 #
# Anomaly alarm                                   #
#                                                 #
###################################################
resource "aws_ce_anomaly_monitor" "serviceanomaly" {
  name                  = "ServiceMonitor"
  monitor_type          = "DIMENSIONAL"
  monitor_dimension     = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "mainsubscription" {
  name      = "RealtimeAnomalySubscription"
  threshold = 250
  frequency = "IMMEDIATE"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.serviceanomaly.arn,
  ]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.alarms_to_pagerduty.arn
  }
}
