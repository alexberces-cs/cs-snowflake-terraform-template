variable "db_name" {}
variable "elt_role_name" {}
variable "bi_role_name" {}
variable "elt_wh_name" {}
variable "bi_wh_name" {}

variable "elt_user_name" {
  type        = string
  description = "Name of the ELT service user, e.g. SVC_ELT_DEV"
}

variable "bi_user_name" {
  type        = string
  description = "Name of the BI service user, e.g. SVC_BI_DEV"
}

variable "elt_user_public_key" {
  type        = string
  description = "RSA public key for the ELT user, on one line without the BEGIN/END lines"
}

variable "bi_user_public_key" {
  type        = string
  description = "RSA public key for the BI user, on one line without the BEGIN/END lines"
}

variable "network_policy_name" {
  type        = string
  description = "Name of the service user network policy, e.g. DEV_SERVICE_USERS_POLICY"
}

variable "allowed_ip_list" {
  type        = list(string)
  description = "CIDR ranges the service users can connect from. Empty = no restriction"
  default     = []
}
