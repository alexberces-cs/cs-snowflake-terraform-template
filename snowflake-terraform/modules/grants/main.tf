terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

# =============================================================================
# How access fits together
#
#   SYSADMIN
#     ├── ELT_<ENV>_ROLE (account role) ── USAGE, OPERATE on ELT warehouse
#     │      └── <DB>.ELT_<ENV>_ROLE (database role) ── all privileges on schemas
#     └── BI_<ENV>_ROLE  (account role) ── USAGE on BI warehouse
#            └── <DB>.BI_<ENV>_ROLE  (database role) ── read-only on BI schemas
#
# Users and service users are granted the ACCOUNT role. They inherit everything
# the database role holds. Warehouses are account-level objects, so warehouse
# grants must go to account roles: database roles can't hold them.
# =============================================================================

# --- Database roles -> account roles (existing) ------------------------------
resource "snowflake_grant_database_role" "grant_elt_db_role" {
  database_role_name = var.elt_db_role.fqn
  parent_role_name   = var.elt_role_name
}

resource "snowflake_grant_database_role" "grant_bi_db_role" {
  database_role_name = var.bi_db_role.fqn
  parent_role_name   = var.bi_role_name
}

# --- NEW: account roles -> SYSADMIN ------------------------------------------
# Keeps the custom roles inside Snowflake's system role hierarchy, so SYSADMIN
# can see and manage anything these roles create.
resource "snowflake_grant_account_role" "elt_role_to_sysadmin" {
  role_name        = var.elt_role_name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "bi_role_to_sysadmin" {
  role_name        = var.bi_role_name
  parent_role_name = "SYSADMIN"
}

# --- NEW: warehouse access ---------------------------------------------------
# Without USAGE a role can't run any query, even if it can see the data.
# OPERATE lets ELT jobs resume or suspend their own warehouse.
resource "snowflake_grant_privileges_to_account_role" "elt_wh_usage" {
  account_role_name = var.elt_role_name
  privileges        = ["USAGE", "OPERATE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.elt_wh_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "bi_wh_usage" {
  account_role_name = var.bi_role_name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.bi_wh_name
  }
}

# --- Database privileges (existing) ------------------------------------------
resource "snowflake_grant_privileges_to_database_role" "grant_db_privileges_elt_db_role" {
  privileges         = ["USAGE"]
  database_role_name = var.elt_db_role.fqn
  on_database        = var.elt_db_role.database
}

resource "snowflake_grant_privileges_to_database_role" "grant_db_privileges_bi_db_role" {
  privileges         = ["USAGE"]
  database_role_name = var.bi_db_role.fqn
  on_database        = var.bi_db_role.database
}

# --- ELT: full control of all current and future schemas (existing) ----------
resource "snowflake_grant_privileges_to_database_role" "grant_all_schema_privileges_elt_db_role" {
  database_role_name = var.elt_db_role.fqn
  on_schema {
    all_schemas_in_database = var.elt_db_role.database
  }
  all_privileges = true
}

resource "snowflake_grant_privileges_to_database_role" "grant_future_schema_privileges_elt_db_role" {
  database_role_name = var.elt_db_role.fqn
  on_schema {
    future_schemas_in_database = var.elt_db_role.database
  }
  all_privileges = true
}

# --- NEW: BI read-only access to the reporting schemas -----------------------
# By default BI can only read the TGT schema (set bi_read_schemas to change).
# "all" covers tables and views that exist today; "future" covers everything
# ELT creates later, so new tables are readable without another apply.
locals {
  bi_schema_fqns = { for s in var.bi_read_schemas : s => "\"${var.bi_db_role.database}\".\"${s}\"" }

  bi_read_grants = {
    for pair in setproduct(var.bi_read_schemas, ["TABLES", "VIEWS"]) :
    "${pair[0]}_${pair[1]}" => { schema = pair[0], object_type_plural = pair[1] }
  }
}

resource "snowflake_grant_privileges_to_database_role" "bi_schema_usage" {
  for_each           = local.bi_schema_fqns
  privileges         = ["USAGE"]
  database_role_name = var.bi_db_role.fqn
  on_schema {
    schema_name = each.value
  }
}

resource "snowflake_grant_privileges_to_database_role" "bi_select_existing" {
  for_each           = local.bi_read_grants
  privileges         = ["SELECT"]
  database_role_name = var.bi_db_role.fqn
  on_schema_object {
    all {
      object_type_plural = each.value.object_type_plural
      in_schema          = local.bi_schema_fqns[each.value.schema]
    }
  }
}

resource "snowflake_grant_privileges_to_database_role" "bi_select_future" {
  for_each           = local.bi_read_grants
  privileges         = ["SELECT"]
  database_role_name = var.bi_db_role.fqn
  on_schema_object {
    future {
      object_type_plural = each.value.object_type_plural
      in_schema          = local.bi_schema_fqns[each.value.schema]
    }
  }
}
