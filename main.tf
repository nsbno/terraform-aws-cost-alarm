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

  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.serviceanomaly.arn,
  ]

  subscriber {
    type    = "EMAIL"
    address = "aws-budget-alarms-email.obdw3nwx@vyutv.pagerduty.com"
  }

  dynamic "subscriber" {
    for_each = var.notification_emails
    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }
}
