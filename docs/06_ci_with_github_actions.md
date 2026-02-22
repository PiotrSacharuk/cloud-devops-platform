# Cloud / Terraform Learning

## CI for Terraform (fmt, validate, plan with GitHub Actions)

### 🎯 Goal

Introduce a lightweight but robust CI stage for the Terraform project that runs on every PR and push:

* Enforce canonical Terraform formatting (`terraform fmt`).
* Validate configuration for all environments (`dev`, `staging`, `prod`) without touching real AWS services.
* Generate a safe `terraform plan` in CI using AWS OIDC, real remote state (S3 + DynamoDB), and no static AWS keys.

## 🧩 Scope

* Repository:
  * Single Terraform codebase with multiple environments:
    * `envs/dev`
    * `envs/staging`
    * `envs/prod`
  * Shared modules:
    * `modules/network`
    * `modules/ec2`
* CI platform:
  * GitHub Actions.
* AWS integration:
  * Remote state backend: S3 + DynamoDB state locking.
  * One IAM role (`github-actions-terraform-role`) assumed via OIDC from GitHub Actions.
* CI stages covered:
  * Formatting (`fmt`).
  * Static configuration validation (`validate`).
  * Read-only planning (`plan`) per environment.

### 🛠 Key Steps (fmt + validate)

1. Added a GitHub Actions workflow for Terraform quality checks:
   * `hashicorp/setup-terraform@v3` used to install the Terraform CLI. [web:431]
   * `fmt` job:
     * Runs `terraform fmt -check -recursive` at the repo root to enforce formatting. [web:433]
   * `validate` job:
     * Uses a matrix over `envs/dev`, `envs/staging`, `envs/prod`.
     * For each env:
       * Runs `terraform init -backend=false` (no S3/DynamoDB access required).
       * Runs `terraform validate` to catch configuration errors early. [web:280]

2. Enabled `TF_INPUT=0` in CI:
   * Ensures Terraform never waits for interactive input in GitHub Actions.
   * Any missing required variable fails fast instead of hanging. [web:379][web:387]

3. Branch protection (conceptually prepared):
   * CI jobs are designed to be used as required status checks before merging.
   * Checks: formatting + validation for all environments.

### 🛠 Key Steps (plan with AWS OIDC)

1. Configured AWS OIDC for GitHub Actions:
   * Created an IAM Identity Provider for `https://token.actions.githubusercontent.com` with audience `sts.amazonaws.com`. [web:359][web:321]
   * Created a single IAM role `github-actions-terraform-role` with:
     * Trust policy allowing `sts:AssumeRoleWithWebIdentity` from the GitHub OIDC provider, scoped to this repository. [web:321]
     * Permissions to:
       * Read/write Terraform state in S3 (GetObject, PutObject, ListBucket on the specific state key prefix). [web:51][web:343]
       * Manage DynamoDB locks (DescribeTable, GetItem, PutItem, DeleteItem on the lock table). [web:51][web:343]
       * Read environment resources required for `terraform plan` (e.g., VPC, subnets, IAM roles).

2. Extended GitHub Actions workflow with a `plan` job:
   * Uses a matrix over environments: `dev`, `staging`, `prod`.
   * For each env:
     * Assumes `github-actions-terraform-role` via `aws-actions/configure-aws-credentials@v4` (OIDC, no static secrets). [web:320]
     * Runs:
       * `terraform init -input=false -reconfigure` in `envs/<env>` to connect to real S3/DynamoDB backend.
       * `terraform plan -input=false -no-color -lock-timeout=5m -out=tfplan`.
       * `terraform show -no-color tfplan > plan.txt`.
     * Uploads `plan.txt` as a build artifact named `plan-envs-<env>`.

3. Prevented state lock contention:
   * Added per-environment `concurrency`:
     * `concurrency.group = terraform-plan-envs-${{ matrix.env }}`
     * `cancel-in-progress = true`
   * Ensures that only one plan runs at a time per environment, avoiding stuck DynamoDB locks. [web:341][web:413]

4. Introduced CI-specific variable files:
   * Added `ci.auto.tfvars` per environment:
     * `envs/dev/ci.auto.tfvars`
     * `envs/staging/ci.auto.tfvars`
     * `envs/prod/ci.auto.tfvars`
   * Each file provides non-interactive values for required variables, designed for CI:
     * Safe defaults for `aws_region`, `environment`, `ami_id`, `instance_type`.
     * `enable_ssh = false` and `allowed_ssh_cidr = "127.0.0.1/32"` to avoid dependence on local SSH keys in CI.
   * Terraform automatically loads `*.auto.tfvars` in each env directory. [web:392]

5. Fixed `enable_ssh` wiring in env configs:
   * Ensured that `envs/*/main.tf` passes `enable_ssh = var.enable_ssh` into modules:
     * No more hardcoded `enable_ssh = true`.
   * This allows CI to disable SSH via tfvars while developers keep SSH enabled locally with their own `terraform.tfvars`.

6. Ensured Git hygiene and safety:
   * `terraform.tfvars` remains local-only and is **not** committed.
   * Binary plan files (`tfplan`) and state (`terraform.tfstate*`) are ignored via `.gitignore`.
   * Only `plan.txt` (rendered text) is uploaded as a CI artifact, not the binary plan itself.

### 🧪 Validation

* CI:
  * PRs and pushes trigger:
    * `fmt (recursive)` – formatting check.
    * `validate (envs/dev)`, `validate (envs/staging)`, `validate (envs/prod)` – static validation per env. [web:280]
    * `plan (dev)`, `plan (staging)`, `plan (prod)` – full plans against real remote state, using AWS OIDC. [web:320]
  * All jobs are green for the Day 7 PR.

* Terraform plan artifacts:
  * For each environment, `plan-envs-<env>` artifact contains `plan.txt`:
    * Can be downloaded from the GitHub Actions UI and inspected before applying manually.

* Locking:
  * Verified that plans can run sequentially without “Error acquiring the state lock” once concurrency is enabled and old locks are cleaned up using `terraform force-unlock` when necessary. [web:413][web:415]

### 📄 Files Introduced / Updated

* `.github/workflows/terraform-ci.yml`
  * `fmt` job – `terraform fmt -check -recursive`.
  * `validate` job – matrix over `envs/dev`, `envs/staging`, `envs/prod` with `terraform init -backend=false` + `terraform validate`.
  * `plan` job – matrix over environments, using AWS OIDC role for remote state and `terraform plan`.
* `envs/dev/ci.auto.tfvars`
* `envs/staging/ci.auto.tfvars`
* `envs/prod/ci.auto.tfvars`
* Existing env files (`envs/*/*.tf`) updated to:
  * Use `enable_ssh` as a variable, not a hardcoded literal.
  * Remain compatible with both local SSH-enabled flows and CI SSH-disabled flows.
* `.gitignore`:
  * Confirmed ignore rules for `tfplan`, `*.tfplan`, `.terraform/`, and `terraform.tfstate*` remain in effect.

### ✅ Outcome

* Terraform codebase now has a **repeatable CI gate**:
  * Formatting enforced.
  * Configurations validated for all environments without hitting AWS.
  * Plans generated safely in CI against the real remote state, without static AWS keys.

* AWS integration is secured:
  * GitHub Actions authenticates to AWS using a short-lived OIDC-based IAM role instead of long-lived access keys. [web:321][web:359]

* Developer experience is clean:
  * Local dev can keep using SSH in `dev` via local `terraform.tfvars`.
  * CI always uses SSH-free settings (`enable_ssh=false`), avoiding brittle dependencies on runner-specific SSH keys.

* Project is ready for the next steps:
  * Adding manual approvals and `terraform apply` stages in CI.
  * Potential future split into separate workflows per environment or per deployment type (e.g., “plan-only” vs “plan+apply”).
