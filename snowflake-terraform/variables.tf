# snowflake credentials
variable "snowflake_account" {}
variable "snowflake_org" {}
variable "snowflake_user" {}
variable "snowflake_role" {}
variable "snowflake_private_key" {sensitive = true}

# snowflake objects
variable "db_name" {}
variable "elt_wh_name" {}
variable "bi_wh_name" {}

variable "db_schema_name" {}

# roles
variable "elt_role_name" {}
variable "elt_db_role_name" {}

variable "bi_role_name" {}
variable "bi_db_role_name" {}
