data "aws_iam_policy_document" "sns" {
  policy_id = "__default_policy_ID"
  statement {
    effect = "Allow"
    sid    = "__default_statement_ID"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        local.current_account_id,
      ]
    }
    resources = [
      aws_sns_topic.budgetalarms.arn,
    ]
  }

  statement {
    effect = "Allow"
    sid    = "AllowAWSBudgets"
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.budgetalarms.arn]
  }
}
