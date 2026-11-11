# database
db_name = "TST_DB"

# warehouse
elt_wh_name = "ELT_TST_WH"
bi_wh_name  = "BI_TST_WH"

# schema
db_schema_name = ["ACQ", "INT", "TGT", "TRF"]

# roles
elt_role_name    = "ELT_TST_ROLE"
elt_db_role_name = "ELT_TST_ROLE"

bi_role_name    = "BI_TST_ROLE"
bi_db_role_name = "BI_TST_ROLE"

# --- NEW -----------------------------------------------------------------

# cost controls: credits per month across both warehouses
resource_monitor_name        = "TST_MONITOR"
monthly_credit_quota         = 30
monitor_notify_users         = [] # e.g. ["JANE_DOE"], users need a verified email
statement_timeout_in_seconds = 3600

# BI can read these schemas only
bi_read_schemas = ["TGT"]

# service users: paste each tool's PUBLIC key on one line, without BEGIN/END lines
elt_user_name       = "SVC_ELT_TST"
bi_user_name        = "SVC_BI_TST"
elt_user_public_key = "REPLACE_WITH_ELT_PUBLIC_KEY"
bi_user_public_key  = "REPLACE_WITH_BI_PUBLIC_KEY"

# network policy for the service users: leave empty to allow any IP
network_policy_name = "TST_SERVICE_USERS_POLICY"
allowed_ip_list     = [] # e.g. ["203.0.113.0/24"]

# ingestion from Azure (optional)
enable_ingestion         = false
storage_integration_name = "TST_AZURE_LANDING_INT"
azure_tenant_id          = "00000000-0000-0000-0000-000000000000"
landing_url              = "azure://<storageaccount>.blob.core.windows.net/<container>/tst/"
