# Cloud / Terraform Learning

## Static Code Analysis with TFLint

### 🎯 Goal

Enhance the Terraform CI pipeline by introducing **static code analysis** using [TFLint](https://github.com/terraform-linters/tflint). The goal is to enforce AWS best practices, ensure strict variable typing, mandate documentation (descriptions), and catch provider-specific errors before running `terraform plan` or `apply`.

### 🧩 Scope

* **Repository:**
  * All environments (`envs/dev`, `envs/staging`, `envs/prod`).
  * Shared modules (`modules/network`, `modules/ec2`).
* **CI Platform:**
  * GitHub Actions (`.github/workflows/terraform-ci.yml`).
* **Tooling:**
  * TFLint with the `aws` plugin ruleset.

### 🛠 Key Steps

1. **TFLint Configuration:**
   * Introduced `.tflint.hcl` at the repository root.
   * Enabled the `aws` plugin to catch cloud-specific misconfigurations (e.g., invalid instance types).
   * Enforced strict rules:
     * `terraform_naming_convention` (snake_case).
     * `terraform_documented_variables` and `terraform_documented_outputs`.
     * `terraform_typed_variables`.
     * `terraform_required_version` and `terraform_required_providers`.

2. **Pipeline Integration:**
   * Added a `tflint` job to the GitHub Actions matrix.
   * Placed it strategically: `fmt` -> `tflint` -> `validate` -> `plan`.
   * Ensured it runs recursively across all environment directories.

3. **Resolving Technical Debt:**
   * **Versioning:** Added `required_version = ">= 1.14.0"` and `required_providers` with `version = "~> 6.33.0"` to all `main.tf` files to satisfy TFLint and align with existing `.terraform.lock.hcl` files.
   * **Typing:** Added explicit `type` definitions (e.g., `string`, `bool`) to all variables in `variables.tf`.
   * **Documentation:** Added `description` fields to every variable and output across the entire codebase.

4. **CI Report Fix:**
   * Fixed the PR comment generation step.
   * Updated the `needs` array in the `report` job to include `[fmt, tflint, validate, plan]`. This ensures the script has access to the `${{ needs.<job>.result }}` context for all steps, fixing the issue where statuses appeared as empty (`****`).

### 🧪 Validation

* **Local Verification:** Ran `tflint --recursive` locally to ensure zero warnings or errors.
* **CI Pipeline:** Pushed changes to trigger GitHub Actions.
  * Verified that TFLint correctly blocks the pipeline (exit code 2) when descriptions or types are missing.
  * Verified that the pipeline succeeds once all rules are satisfied.
* **Reporting:** Confirmed the PR comment correctly displays the outcome of each stage (e.g., `success`, `failure`, `skipped`).

### 📄 Files Introduced / Updated

* `.tflint.hcl` – Global TFLint configuration and rule definitions.
* `.github/workflows/terraform-ci.yml` – Added `tflint` job and updated `report` job dependencies.
* `envs/*/*.tf` – Added required provider blocks, variable types, and descriptions.
* `modules/*/*.tf` – Added variable and output descriptions.

### ✅ Outcome

* The codebase is now strictly typed, fully documented, and adheres to canonical naming conventions.
* The CI pipeline is more robust, catching configuration drift and syntax issues earlier and faster without needing AWS credentials.
* The automated PR report accurately reflects the health of every pipeline stage.