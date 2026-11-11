variable "elt_role_name" {}
variable "bi_role_name" {}

variable "elt_db_role" {
  type = object({
    database = string
    name     = string
    fqn      = string
  })
}

variable "bi_db_role" {
  type = object({
    database = string
    name     = string
    fqn      = string
  })
}

# NEW
variable "elt_wh_name" {
  type        = string
  description = "Warehouse the ELT role can use and operate"
}

variable "bi_wh_name" {
  type        = string
  description = "Warehouse the BI role can use"
}

variable "bi_read_schemas" {
  type        = list(string)
  description = "Schemas the BI role can read (SELECT on all and future tables and views)"
  default     = ["TGT"]
}
