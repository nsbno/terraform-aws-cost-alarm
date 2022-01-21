variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "notification_emails" {
  description = "A list of email addresses to send AWS Budgets notifications to."
  type        = list(string)
  default     = []
}

variable "account_budget_limit_in_usd" {
  description = "If the account spending is forecasted to exceed this limit, a message will be sent to SNS."
  default     = "200.0"
}

variable "env" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = string
}
