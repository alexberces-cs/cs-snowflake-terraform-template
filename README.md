# cs-snowflake-terraform-template

Clear Strategy's starting point for deploying a client's Snowflake environment with Terraform.
Copy this repo for each new client, fill in the settings files, and the pipeline deploys the environment.
No module code needs to change per client.

## What it creates

Per environment (the names below are from `dev.tfvars`):

| Object | Name in dev | Notes |
| --- | --- | --- |
| Database | `DEV_DB` | |
| Schemas | `ACQ`, `INT`, `TRF`, `TGT` | |
| Warehouses | `ELT_DEV_WH`, `BI_DEV_WH` | XSMALL, auto-suspend after 60s, 1-hour query timeout |
| Resource monitor | `DEV_MONITOR` | Monthly credit budget: emails at 75% and 90%, suspends at 100%, cancels queries at 110% |
| Account roles | `ELT_DEV_ROLE`, `BI_DEV_ROLE` | Both granted to SYSADMIN |
| Database roles | `ELT_DEV_ROLE`, `BI_DEV_ROLE` | ELT: full control of all schemas. BI: read-only on `TGT` |
| Service users | `SVC_ELT_DEV`, `SVC_BI_DEV` | Logins for the ELT and BI tools, key-pair only |
| Network policy | `DEV_SERVICE_USERS_POLICY` | Only created if `allowed_ip_list` is filled in |
| Storage integration and stage | `DEV_AZURE_LANDING_INT`, `DEV_DB.ACQ.LANDING_STAGE` | Only created if `enable_ingestion = true` |

How access works: a tool logs in as its service user, which holds an account role. The account role can use its
warehouse and holds a database role, and the database role holds the data permissions.

## Repo layout

```text
cs-snowflake-terraform-template/
├─ .github/workflows/        # checks.yml (pull requests) and deploy.yml (merge to main)
├─ initial-setup/
│  └─ terraform_user.sql     # one-off SQL that creates the user Terraform logs in as
└─ snowflake-terraform/
   ├─ backend/
   │  └─ example.hcl         # copy to dev.hcl with the client's state storage details
   ├─ modules/               # database, schema, warehouse, account_roles, database_roles,
   │                         # grants, service_users, ingestion
   ├─ dev.tfvars             # dev settings
   ├─ tst.tfvars             # tst settings (not deployed by the pipeline yet)
   ├─ main.tf                # connects the modules
   ├─ variables.tf
   ├─ outputs.tf
   ├─ provider.tf
   └─ versions.tf            # Terraform/provider versions and the backend setting
```

## What you need

- ACCOUNTADMIN on the client's Snowflake account
- A GitHub repo for the client, ideally in the client's own GitHub organisation
- Somewhere for the Terraform state file in the client's own cloud (for example an Azure storage account)
- Terraform 1.10 or newer, Git and OpenSSL on your laptop

## Onboarding a new client

### 1. Copy the repo

Create the client's repo from this template.

### 2. Create the Terraform login in Snowflake

Create a key pair for Terraform. Keep the `.p8` file private, and never commit it.

```bash
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out terraform_key.p8 -nocrypt
openssl rsa -in terraform_key.p8 -pubout -out terraform_key.pub
```

Open `initial-setup/terraform_user.sql`, paste the contents of `terraform_key.pub` in place of the placeholder
(on one line, without the `BEGIN`/`END` lines), and run it in a Snowflake worksheet as ACCOUNTADMIN.
It creates the `TERRAFORM_SVC` user.

Find the organization and account names by running this in Snowflake:

```sql
SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME();
```

### 3. Add the GitHub secrets

In the client's repo, go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
| --- | --- |
| `SNOWFLAKE_ORG` | Organization name |
| `SNOWFLAKE_ACCOUNT` | Account name |
| `SNOWFLAKE_USER` | `TERRAFORM_SVC` |
| `SNOWFLAKE_ROLE` | `ACCOUNTADMIN` |
| `SNOWFLAKE_PRIVATE_KEY` | Full contents of `terraform_key.p8`, including the `BEGIN`/`END` lines |

Also add whatever the state storage needs to log in, for example `ARM_ACCESS_KEY` for an Azure storage account.

### 4. Set up the state backend

Terraform keeps a state file recording what it has created. It lives in the **client's** cloud storage and is
handed over with the repo. Clear Strategy doesn't host it.

1. Create the storage in the client's cloud (for Azure: a storage account with a private container called `tfstate`).
2. In `snowflake-terraform/versions.tf`, remove the `#` from the one `backend` line that matches the client's cloud.
3. Copy `backend/example.hcl` to `backend/dev.hcl` and fill in the client's details. Commit `backend/dev.hcl`:
   it holds no secrets, and the pipeline only deploys once it exists.

### 5. Fill in the settings

Edit `snowflake-terraform/dev.tfvars`. These are the settings that change per client:

| Setting | Example | What it does |
| --- | --- | --- |
| `db_name` | `DEV_DB` | Database name |
| `elt_wh_name`, `bi_wh_name` | `ELT_DEV_WH`, `BI_DEV_WH` | Warehouse names |
| `db_schema_name` | `["ACQ", "INT", "TGT", "TRF"]` | Schemas to create |
| `elt_role_name`, `bi_role_name` | `ELT_DEV_ROLE`, `BI_DEV_ROLE` | Account role names |
| `elt_db_role_name`, `bi_db_role_name` | `ELT_DEV_ROLE`, `BI_DEV_ROLE` | Database role names |
| `resource_monitor_name` | `DEV_MONITOR` | Name of the credit budget |
| `monthly_credit_quota` | `20` | Credits per month across both warehouses |
| `monitor_notify_users` | `["JANE_DOE"]` | Users emailed at 75% and 90% (they need a verified email) |
| `statement_timeout_in_seconds` | `3600` | Longest a query can run |
| `bi_read_schemas` | `["TGT"]` | Schemas the BI role can read |
| `elt_user_name`, `bi_user_name` | `SVC_ELT_DEV`, `SVC_BI_DEV` | Tool login names |
| `elt_user_public_key`, `bi_user_public_key` | `MIIBIjANBg...` | Each tool's public key, on one line without `BEGIN`/`END` lines |
| `network_policy_name` | `DEV_SERVICE_USERS_POLICY` | Name of the IP restriction |
| `allowed_ip_list` | `["203.0.113.0/24"]` | IP ranges the tools can log in from. Empty = no restriction |
| `enable_ingestion` | `false` | `true` creates the Azure storage integration and stage |
| `storage_integration_name` | `DEV_AZURE_LANDING_INT` | Only used when ingestion is on |
| `azure_tenant_id` | `<client tenant id>` | Only used when ingestion is on |
| `landing_url` | `azure://<account>.blob.core.windows.net/<container>/dev/` | Only used when ingestion is on |

Each tool (for example the ELT tool and Power BI) gets its own key pair, made with the same `openssl`
commands as in step 2. The private key goes into the tool, and the public key goes here. Public keys are safe to commit.

Account-level names include the environment (`DEV_`, `TST_`) because environments may share one Snowflake account.

### 6. Deploy

1. Open a pull request with the client's settings. The checks run and a plan shows what will be created in dev.
2. Review the plan and merge. Dev deploys automatically.
3. If ingestion is on, send the `azure_consent_url` output from the deploy log to the client's Azure admin.
   They approve it and give the Snowflake app the **Storage Blob Data Reader** role on the storage account.

## The pipeline

| Workflow | Runs when | What it does |
| --- | --- | --- |
| `checks.yml` | A pull request to `main` | Checks formatting and that the code is valid, then plans dev |
| `deploy.yml` | A merge to `main` that changes `snowflake-terraform/` | Deploys dev, applying exactly the plan it made |

Both workflows skip the plan and deploy (with a note in the run summary) until `backend/dev.hcl` exists, so the
template itself never deploys.

Protect `main` under **Settings → Branches** by requiring a pull request, an approval and passing checks,
so nothing deploys without a review.

**Adding tst:** `tst.tfvars` is ready, but the pipeline doesn't deploy it yet. To add it, copy the `deploy-dev`
job in `deploy.yml` as `deploy-tst`, change `dev` to `tst`, and add `needs: deploy-dev`. Do the same for
`plan-dev` in `checks.yml`, and create `backend/tst.hcl` with its own `key`.

## Running Terraform from your laptop

Useful for testing in a sandbox account. Set the login details for the current terminal session:

```bash
# Mac / Linux
export TF_VAR_snowflake_org=<org name>
export TF_VAR_snowflake_account=<account name>
export TF_VAR_snowflake_user=TERRAFORM_SVC
export TF_VAR_snowflake_role=ACCOUNTADMIN
export TF_VAR_snowflake_private_key="$(cat ~/.ssh/terraform_key.p8)"
```

```powershell
# Windows PowerShell
$env:TF_VAR_snowflake_org = "<org name>"
$env:TF_VAR_snowflake_account = "<account name>"
$env:TF_VAR_snowflake_user = "TERRAFORM_SVC"
$env:TF_VAR_snowflake_role = "ACCOUNTADMIN"
$env:TF_VAR_snowflake_private_key = Get-Content -Raw "$HOME\.ssh\terraform_key.p8"
```

Then, from inside `snowflake-terraform/`:

```bash
terraform init -backend-config=backend/dev.hcl
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
terraform destroy -var-file=dev.tfvars   # removes everything again
```

In PowerShell, put quotes around any option containing `=`, for example `terraform plan "-var-file=dev.tfvars"`.

Without a backend configured, Terraform keeps state in a local `terraform.tfstate` file. That's fine for a quick
test, and `.gitignore` keeps it out of git. Never commit a state file.

## Handover

At the end of the engagement, the client owns the repo, the state storage and all the keys. Replace the
Terraform key pair (generate a new one, set it with `ALTER USER TERRAFORM_SVC SET RSA_PUBLIC_KEY = '...'`, and
update the `SNOWFLAKE_PRIVATE_KEY` secret), and remove Clear Strategy's access to the repo and the cloud account.
