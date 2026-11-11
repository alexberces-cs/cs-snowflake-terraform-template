output "elt_user_name" {
  value = snowflake_service_user.elt.name
}

output "bi_user_name" {
  value = snowflake_service_user.bi.name
}
