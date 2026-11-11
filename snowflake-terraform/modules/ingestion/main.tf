terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

# =============================================================================
# Ingestion from Azure Blob / ADLS (NEW, optional: enable_ingestion = true)
#
#   Azure container ──(storage integration)──> Snowflake
#                                                └─ <DB>.ACQ.LANDING_STAGE
#
# 1. The storage integration lets Snowflake reach the container through its
#    own Entra ID app, so no SAS token or key is stored anywhere.
# 2. The external stage points at the container through that integration and
#    sets a default CSV file format, so the ELT role can run COPY INTO.
# 3. The ELT database role gets USAGE on the stage.
#
# After the first apply, an Azure admin opens the consent_url output, grants
# consent, and gives the Snowflake app (multi_tenant_app_name output) the
# "Storage Blob Data Reader" role on the storage account.
#
# Creating an integration needs ACCOUNTADMIN or the CREATE INTEGRATION
# privilege on the role Terraform runs as.
# For AWS, use snowflake_storage_integration_aws + snowflake_stage_external_s3.
# =============================================================================

resource "snowflake_storage_integration_azure" "landing" {
  name                      = var.storage_integration_name
  enabled                   = true
  azure_tenant_id           = var.azure_tenant_id
  storage_allowed_locations = [var.landing_url]
  comment                   = "Read access to the client's landing container"
}

resource "snowflake_stage_external_azure" "landing" {
  name                = "LANDING_STAGE"
  database            = var.db_name
  schema              = var.landing_schema
  url                 = var.landing_url
  storage_integration = snowflake_storage_integration_azure.landing.name
  comment             = "Landing files from the client's Azure container"

  # Inline file format, so no separate file format object is needed.
  file_format {
    csv {
      skip_header                  = 1
      field_optionally_enclosed_by = "\""
    }
  }
}

resource "snowflake_grant_privileges_to_database_role" "elt_stage_usage" {
  privileges         = ["USAGE"]
  database_role_name = var.elt_db_role_fqn
  on_schema_object {
    object_type = "STAGE"
    object_name = snowflake_stage_external_azure.landing.fully_qualified_name
  }
}
