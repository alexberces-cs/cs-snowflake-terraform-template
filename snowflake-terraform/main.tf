# =============================================================================
# Snowflake environment for one client and one environment (dev / tst / prd).
# Everything is driven by <env>.tfvars.
#
# Build order (Terraform works it out from the references below):
#   database ─> schemas ─┐
#   warehouse + monitor ─┼─> grants ─> service_users
#   account_roles ───────┤
#   database_roles ──────┘
#   ingestion (optional, needs schemas and database roles)
# =============================================================================

module "database" {
  source  = "./modules/database"
  db_name = var.db_name
}

module "warehouse" {
  source                       = "./modules/warehouse"
  elt_wh_name                  = var.elt_wh_name
  bi_wh_name                   = var.bi_wh_name
  resource_monitor_name        = var.resource_monitor_name
  monthly_credit_quota         = var.monthly_credit_quota
  monitor_notify_users         = var.monitor_notify_users
  statement_timeout_in_seconds = var.statement_timeout_in_seconds
}

module "schema" {
  source         = "./modules/schema"
  for_each       = toset(var.db_schema_name)
  db_schema_name = each.key
  db_name        = module.database.db_name
}

module "account_roles" {
  source        = "./modules/account_roles"
  elt_role_name = var.elt_role_name
  bi_role_name  = var.bi_role_name
}

module "database_roles" {
  source           = "./modules/database_roles"
  elt_db_role_name = var.elt_db_role_name
  bi_db_role_name  = var.bi_db_role_name
  db_name          = module.database.db_name
}

module "grants" {
  source          = "./modules/grants"
  elt_role_name   = module.account_roles.elt_role_name
  bi_role_name    = module.account_roles.bi_role_name
  elt_db_role     = module.database_roles.elt_db_role
  bi_db_role      = module.database_roles.bi_db_role
  elt_wh_name     = module.warehouse.elt_wh_name
  bi_wh_name      = module.warehouse.bi_wh_name
  bi_read_schemas = var.bi_read_schemas

  # BI schema grants need the schemas to exist first.
  depends_on = [module.schema]
}

module "service_users" {
  source              = "./modules/service_users"
  db_name             = module.database.db_name
  elt_role_name       = module.account_roles.elt_role_name
  bi_role_name        = module.account_roles.bi_role_name
  elt_wh_name         = module.warehouse.elt_wh_name
  bi_wh_name          = module.warehouse.bi_wh_name
  elt_user_name       = var.elt_user_name
  bi_user_name        = var.bi_user_name
  elt_user_public_key = var.elt_user_public_key
  bi_user_public_key  = var.bi_user_public_key
  network_policy_name = var.network_policy_name
  allowed_ip_list     = var.allowed_ip_list
}

module "ingestion" {
  source                   = "./modules/ingestion"
  count                    = var.enable_ingestion ? 1 : 0
  db_name                  = module.database.db_name
  elt_db_role_fqn          = module.database_roles.elt_db_role.fqn
  storage_integration_name = var.storage_integration_name
  azure_tenant_id          = var.azure_tenant_id
  landing_url              = var.landing_url

  depends_on = [module.schema]
}