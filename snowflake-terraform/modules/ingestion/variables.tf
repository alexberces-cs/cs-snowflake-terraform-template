variable "db_name" {}

variable "elt_db_role_fqn" {
  type        = string
  description = "Fully qualified ELT database role that can use the stage"
}

variable "storage_integration_name" {
  type        = string
  description = "Account-level integration name, e.g. DEV_AZURE_LANDING_INT"
}

variable "azure_tenant_id" {
  type        = string
  description = "Client's Entra ID (Azure AD) tenant ID"
}

variable "landing_url" {
  type        = string
  description = "azure://<account>.blob.core.windows.net/<container>/<path>/"
}

variable "landing_schema" {
  type        = string
  description = "Schema that holds the stage"
  default     = "ACQ"
}
