output "stage_name" {
  value = snowflake_stage_external_azure.landing.fully_qualified_name
}

# Give these two values to the client's Azure admin after the first apply.
output "azure_consent_url" {
  value = snowflake_storage_integration_azure.landing.describe_output[0].consent_url
}

output "azure_multi_tenant_app_name" {
  value = snowflake_storage_integration_azure.landing.describe_output[0].multi_tenant_app_name
}
