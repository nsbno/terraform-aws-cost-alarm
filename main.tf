provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}

locals {
  current_account_id = data.aws_caller_identity.this.account_id
}

resource "aws_sns_topic" "budget" {
  name = "${var.env}-${var.account_name}-anomaly-alarm"
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
  name              = "ServiceMonitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "mainsubscription" {
  name = "RealtimeAnomalySubscription"

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [var.anomaly_threshold_in_usd]
      }
    }
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = [var.anomaly_threshold_percentage]
      }
    }
  }

  frequency = "IMMEDIATE"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.serviceanomaly.arn,
  ]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.budget.arn
  }
}
