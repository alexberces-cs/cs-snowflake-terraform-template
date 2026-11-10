variable "elt_wh_name" {}
variable "bi_wh_name" {}

variable "resource_monitor_name" {
  type        = string
  description = "Name of the environment's resource monitor, e.g. DEV_MONITOR"
}

variable "monthly_credit_quota" {
  type        = number
  description = "Credits per month across the ELT and BI warehouses before suspension"
}

variable "monitor_notify_users" {
  type        = list(string)
  description = "Snowflake users (with verified emails) who get resource monitor alerts"
  default     = []
}

variable "statement_timeout_in_seconds" {
  type        = number
  description = "Cancel any query running longer than this. 3600 = 1 hour"
  default     = 3600
}
