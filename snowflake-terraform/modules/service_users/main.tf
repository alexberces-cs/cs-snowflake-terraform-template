terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

# =============================================================================
# Service users (NEW)
#
# Non-human logins for the tools that connect to Snowflake:
#   SVC_ELT_<ENV>  -> the ingestion/transformation tool (ADF, Fivetran, dbt...)
#   SVC_BI_<ENV>   -> the BI tool (Power BI, Tableau...)
#
# TYPE = SERVICE users can't use passwords or MFA. They sign in with an RSA
# key pair: Terraform stores only the PUBLIC key, and the private key stays in
# the tool's secret store. Each user gets the matching account role, so it
# inherits that role's warehouse and data access from the grants module.
# =============================================================================

# Optional network policy: if allowed_ip_list is empty, no policy is created
# and the service users can connect from anywhere.
resource "snowflake_network_policy" "service_users" {
  count           = length(var.allowed_ip_list) > 0 ? 1 : 0
  name            = var.network_policy_name
  allowed_ip_list = var.allowed_ip_list
  comment         = "Restricts service users to the client's tool and CI IP ranges"
}

locals {
  network_policy = length(var.allowed_ip_list) > 0 ? snowflake_network_policy.service_users[0].name : null
}

resource "snowflake_service_user" "elt" {
  name              = var.elt_user_name
  comment           = "Service user for the ELT / ingestion tool"
  default_role      = var.elt_role_name
  default_warehouse = var.elt_wh_name
  default_namespace = var.db_name
  rsa_public_key    = var.elt_user_public_key
  network_policy    = local.network_policy
}

resource "snowflake_service_user" "bi" {
  name              = var.bi_user_name
  comment           = "Service user for the BI tool"
  default_role      = var.bi_role_name
  default_warehouse = var.bi_wh_name
  default_namespace = var.db_name
  rsa_public_key    = var.bi_user_public_key
  network_policy    = local.network_policy
}

# default_role only sets the role used at login. It doesn't grant the role,
# so the grants below are required.
resource "snowflake_grant_account_role" "elt_role_to_user" {
  role_name = var.elt_role_name
  user_name = snowflake_service_user.elt.name
}

resource "snowflake_grant_account_role" "bi_role_to_user" {
  role_name = var.bi_role_name
  user_name = snowflake_service_user.bi.name
}
