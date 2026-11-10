terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.22"
    }
  }
  # statefile backend - set up per client, in the client's cloud account.
  # uncomment one of the options below, then run:
  #   terraform init -backend-config=backend/<env>.hcl 

  # backend "azurerm" {}   # Azure Storage
  # backend "s3" {}        # AWS S3 (add use_lockfile = true in the .hcl)
  # backend "gcs" {}       # Google Cloud Storage
}