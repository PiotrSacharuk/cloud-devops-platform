# Cloud / Terraform Learning

## Free Tier Guardrails & Global Environment Refactoring

### 🎯 Goal

Implement FinOps best practices by setting up a CloudWatch Billing Alarm to proactively notify administrators if infrastructure costs exceed AWS Free Tier limits. Simultaneously, establish a dedicated `global` workspace to manage account-wide resources independently of application lifecycles, and resolve IaC configuration conflicts.

### 🧩 Scope

* **New Module:** `modules/billing_alarm` (CloudWatch, SNS).
* **Environments:** Created `envs/global`; refactored `envs/dev`, `envs/staging`, `envs/prod`.
* **CI/CD:** `.github/workflows/terraform-ci.yml`.

### 🛠 Key Steps

1. **Creating the Alerting Mechanism (Billing Alarm):**
   * Provisioned an `aws_sns_topic` and an email `aws_sns_topic_subscription` to handle billing alerts.
   * Defined an `aws_cloudwatch_metric_alarm` tracking the `AWS/Billing` namespace (`EstimatedCharges` metric).
   * Set the threshold to `$1.00` to ensure strict adherence to the zero-cost architecture constraint.

2. **Establishing the Global Environment:**
   * **The Challenge:** Deploying account-wide metrics in an ephemeral environment like `dev` leads to alarm deletion upon `terraform destroy`, and deploying it across multiple environments causes duplicate alerts.
   * **The Solution:** Created `envs/global` with a dedicated S3 backend state key (`cloud-devops-platform/global/terraform.tfstate`).
   * Invoked the `billing_alarm` module inside `envs/global` to ensure continuous, uninterrupted cost monitoring.

3. **Resolving Variable Precedence Conflicts:**
   * **The Issue:** Terraform automatically loads any file ending in `.auto.tfvars`. The dummy CI variables in `ci.auto.tfvars` were overriding local `terraform.tfvars` values during manual executions, causing invalid emails to be registered with SNS.
   * **The Fix:** Renamed `ci.auto.tfvars` to `ci.tfvars` to disable automatic loading. Modified the GitHub Actions workflow to explicitly inject these test variables using the `-var-file="ci.tfvars"` flag strictly during the `terraform plan` CI step.

4. **Pipeline Matrix Expansion:**
   * Added `envs/global` to the `dir` and `env` matrices in the GitHub Actions workflow, ensuring the new global configuration is continuously integrated.

### 🧪 Validation

* **State Isolation:** The global environment initializes correctly and maintains a separate state file in the S3 bucket.
* **Variable Isolation:** Local `terraform plan` operations no longer default to the dummy CI address.
* **Notification Loop:** After applying the configuration in the global environment, the SNS subscription confirmation was successfully received and acknowledged.

### 📄 Files Introduced / Updated

* `modules/billing_alarm/*` – Defined SNS and CloudWatch resources.
* `envs/global/*` – New workspace containing `main.tf`, `backend.tf`, `variables.tf`, `terraform.tfvars`, `ci.tfvars`.
* `envs/*/ci.tfvars` – Renamed from `*.auto.tfvars`.
* `.github/workflows/terraform-ci.yml` – Updated matrix and plan command.
* `docs/12_free_tier_guardrails.md` – This document.

### ✅ Outcome

* The AWS account is protected by an automated cost guardrail running in a highly scalable, Enterprise-mirrored directory structure.
* We successfully eliminated a configuration drift risk by strictly managing how variables are injected during CI versus local execution.