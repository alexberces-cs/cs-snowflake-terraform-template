# --- Connection (set as TF_VAR_* secrets in CI) -------------------------------
variable "snowflake_account" {}
variable "snowflake_org" {}
variable "snowflake_user" {}
variable "snowflake_role" {}
variable "snowflake_private_key" { sensitive = true }

# --- Database, schemas, warehouses, roles (existing) --------------------------
variable "db_name" {}
variable "elt_wh_name" {}
variable "bi_wh_name" {}

variable "db_schema_name" {}

variable "elt_role_name" {}
variable "elt_db_role_name" {}

variable "bi_role_name" {}
variable "bi_db_role_name" {}

# --- NEW: cost controls -------------------------------------------------------
variable "resource_monitor_name" { type = string }

variable "monthly_credit_quota" { type = number }

variable "monitor_notify_users" {
  type    = list(string)
  default = []
}

variable "statement_timeout_in_seconds" {
  type    = number
  default = 3600
}

# --- NEW: BI read access ------------------------------------------------------
variable "bi_read_schemas" {
  type    = list(string)
  default = ["TGT"]
}

# --- NEW: service users -------------------------------------------------------
variable "elt_user_name" {}
variable "bi_user_name" {}
variable "elt_user_public_key" {}
variable "bi_user_public_key" {}

variable "network_policy_name" {}

variable "allowed_ip_list" {
  type    = list(string)
  default = []
}

# --- NEW: ingestion (optional) ------------------------------------------------
variable "enable_ingestion" {
  type    = bool
  default = false
}

variable "storage_integration_name" {
  type    = string
  default = null
}

variable "azure_tenant_id" {
  type    = string
  default = null
}

variable "landing_url" {
  type    = string
  default = null
}
