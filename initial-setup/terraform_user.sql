-- Run once per client account, as ACCOUNTADMIN.
-- Paste the public key without the BEGIN/END lines.
USE ROLE ACCOUNTADMIN;

CREATE USER IF NOT EXISTS TERRAFORM_SVC
  TYPE = SERVICE
  RSA_PUBLIC_KEY = '<contents of terraform_key.pub>'
  DEFAULT_ROLE = ACCOUNTADMIN
  COMMENT = 'Used by Terraform to deploy this account';

GRANT ROLE ACCOUNTADMIN TO USER TERRAFORM_SVC;