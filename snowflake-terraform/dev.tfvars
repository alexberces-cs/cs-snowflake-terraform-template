# database
db_name = "DEV_DB"

# warehouse
elt_wh_name = "ELT_DEV_WH"
bi_wh_name  = "BI_DEV_WH"

# schema
db_schema_name = ["ACQ", "INT", "TGT", "TRF"]

# roles
elt_role_name    = "ELT_DEV_ROLE"
elt_db_role_name = "ELT_DEV_ROLE"

bi_role_name    = "BI_DEV_ROLE"
bi_db_role_name = "BI_DEV_ROLE"

# --- NEW -----------------------------------------------------------------

# cost controls: credits per month across both warehouses
resource_monitor_name        = "DEV_MONITOR"
monthly_credit_quota         = 20
monitor_notify_users         = [] # e.g. ["JANE_DOE"], users need a verified email
statement_timeout_in_seconds = 3600

# BI can read these schemas only
bi_read_schemas = ["TGT"]

# service users: paste each tool's PUBLIC key on one line, without BEGIN/END lines
elt_user_name       = "SVC_ELT_DEV"
bi_user_name        = "SVC_BI_DEV"
elt_user_public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlfKe+8RB8IqzzdEwtvcUyAgNiYJqfMK9ALxeSm+cnd8ox1g3LRss/7TGt2IODAFr6coPli2/Qn+zwgQSXnQsmQR4p9mQjIW40ji/sDnXBGy8D6F2PHkMMzegOD9J8pkKLQnMPoZMh+rTRlxkVDaK3sxtlzcPh6mmKGgxq++iM1kRsag6iPNsglhsOZLRdCg/21bpDH0g4RaNmP4/oLwFmtGLQ6tGhRroN/rtR4WPSHgG75GuSZyb880suVdOTpmH53VHy5SwqSwwFGP7MPsdJSsQHmH65MtcOJ+BkJUlEC1BMBqcYSIPR756RH4VlCq2D6tptTmVmT144NI+Pn4xmwIDAQAB"
bi_user_public_key  = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlfKe+8RB8IqzzdEwtvcUyAgNiYJqfMK9ALxeSm+cnd8ox1g3LRss/7TGt2IODAFr6coPli2/Qn+zwgQSXnQsmQR4p9mQjIW40ji/sDnXBGy8D6F2PHkMMzegOD9J8pkKLQnMPoZMh+rTRlxkVDaK3sxtlzcPh6mmKGgxq++iM1kRsag6iPNsglhsOZLRdCg/21bpDH0g4RaNmP4/oLwFmtGLQ6tGhRroN/rtR4WPSHgG75GuSZyb880suVdOTpmH53VHy5SwqSwwFGP7MPsdJSsQHmH65MtcOJ+BkJUlEC1BMBqcYSIPR756RH4VlCq2D6tptTmVmT144NI+Pn4xmwIDAQAB"

# network policy for the service users: leave empty to allow any IP
network_policy_name = "DEV_SERVICE_USERS_POLICY"
allowed_ip_list     = [] # e.g. ["203.0.113.0/24"]

# ingestion from Azure (optional)
enable_ingestion         = false
storage_integration_name = "DEV_AZURE_LANDING_INT"
azure_tenant_id          = "00000000-0000-0000-0000-000000000000"
landing_url              = "azure://<storageaccount>.blob.core.windows.net/<container>/dev/"
