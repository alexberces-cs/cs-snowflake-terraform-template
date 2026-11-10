output "elt_wh_name" {
  value = snowflake_warehouse.elt_wh.name
}

output "bi_wh_name" {
  value = snowflake_warehouse.bi_wh.name
}

output "resource_monitor_name" {
  value = snowflake_resource_monitor.env_monitor.name
}
