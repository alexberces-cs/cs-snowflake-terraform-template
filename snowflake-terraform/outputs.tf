output "database" {
  value = module.database.db_name
}

output "warehouses" {
  value = [module.warehouse.elt_wh_name, module.warehouse.bi_wh_name]
}

output "resource_monitor" {
  value = module.warehouse.resource_monitor_name
}

output "service_users" {
  value = [module.service_users.elt_user_name, module.service_users.bi_user_name]
}

# Only set when enable_ingestion = true. Send to the client's Azure admin.
output "azure_consent_url" {
  value = var.enable_ingestion ? module.ingestion[0].azure_consent_url : null
}

output "azure_multi_tenant_app_name" {
  value = var.enable_ingestion ? module.ingestion[0].azure_multi_tenant_app_name : null
}
