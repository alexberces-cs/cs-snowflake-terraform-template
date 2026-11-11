terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

# -----------------------------------------------------------------------------
# Resource monitor (NEW)
# One monitor per environment, attached to both warehouses below. Credit usage
# resets monthly (the Snowflake default when no frequency is set).
#   75% / 90%  -> email notification
#   100%       -> suspend warehouses after running queries finish
#   110%       -> suspend immediately and cancel running queries
# -----------------------------------------------------------------------------
resource "snowflake_resource_monitor" "env_monitor" {
  name         = var.resource_monitor_name
  credit_quota = var.monthly_credit_quota

  notify_triggers           = [75, 90]
  suspend_trigger           = 100
  suspend_immediate_trigger = 110

  # Users must exist and have a verified email to receive notifications.
  notify_users = length(var.monitor_notify_users) > 0 ? var.monitor_notify_users : null
}

resource "snowflake_warehouse" "elt_wh" {
  name                      = var.elt_wh_name
  comment                   = "Warehouse for ingestion and transformation workloads"
  warehouse_type            = "STANDARD"
  warehouse_size            = "XSMALL"
  max_cluster_count         = 1
  min_cluster_count         = 1
  auto_suspend              = 60
  auto_resume               = true
  enable_query_acceleration = false
  initially_suspended       = true

  # NEW: cost guard rails
  resource_monitor             = snowflake_resource_monitor.env_monitor.name
  statement_timeout_in_seconds = var.statement_timeout_in_seconds
}

resource "snowflake_warehouse" "bi_wh" {
  name                      = var.bi_wh_name
  comment                   = "Warehouse for BI tools and analyst queries"
  warehouse_type            = "STANDARD"
  warehouse_size            = "XSMALL"
  max_cluster_count         = 1
  min_cluster_count         = 1
  auto_suspend              = 60
  auto_resume               = true
  enable_query_acceleration = false
  initially_suspended       = true

  # NEW: cost guard rails
  resource_monitor             = snowflake_resource_monitor.env_monitor.name
  statement_timeout_in_seconds = var.statement_timeout_in_seconds
}
