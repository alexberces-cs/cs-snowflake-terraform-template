output "elt_db_role" {
  value = {
    name = snowflake_database_role.elt_db_role.name
    database = snowflake_database_role.elt_db_role.database
    fqn = "${snowflake_database_role.elt_db_role.database}.${snowflake_database_role.elt_db_role.name}"
  }
}

output "bi_db_role" {
  value = {
    name = snowflake_database_role.bi_db_role.name
    database = snowflake_database_role.bi_db_role.database
    fqn = "${snowflake_database_role.bi_db_role.database}.${snowflake_database_role.bi_db_role.name}"
  }
}