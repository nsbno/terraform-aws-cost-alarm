variable "env" {
  description = "The environment in which the cost alarms are for."
  type        = string
}

variable "account_name" {
  description = "The name of your account to distinguish the alarm."
  type        = string
}

variable "anomaly_threshold_in_usd" {
  description = "Anomaly in cost above this limit."
  default     = "50"
}

variable "anomaly_threshold_percentage" {
  description = "Anomaly in cost above this percentage."
  default     = "100"
}
