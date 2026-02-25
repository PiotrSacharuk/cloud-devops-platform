# Cloud / Terraform Learning

## IaC Code Hygiene: Provider Refactoring

### 🎯 Goal

Improve the maintainability and readability of the Terraform codebase by strictly separating provider and backend configurations from actual infrastructure resource definitions.

### 🧩 Scope

* **Environments:** `envs/global`, `envs/dev`, `envs/staging`, `envs/prod`.

### 🛠 Key Steps

1. **Extracting Configuration:**
   * Removed the `terraform` block (which includes required providers and version constraints) from `main.tf` in every environment.
   * Removed the `provider "aws"` block (which handles region injection and default tagging) from `main.tf` in every environment.

2. **Standardizing `providers.tf`:**
   * Created a new, dedicated `providers.tf` file in all four environment directories.
   * Consolidated the extracted configurations into these new files.
   * This structure ensures that `main.tf` is strictly reserved for invoking modules and defining resources, making the codebase easier to navigate and review.

### 🧪 Validation

* **Formatting and Validation:** Ran `terraform fmt` to ensure standard HCL styling and `terraform validate` to confirm that Terraform correctly stitches the `.tf` files together in the directory without recognizing any duplicate definitions.
* **CI/CD Pipeline:** The automated pipeline seamlessly processes the refactored directory structure, proving that the logical separation does not break the execution graph.

### 📄 Files Introduced / Updated

* `envs/*/providers.tf` – New files containing provider configuration.
* `envs/*/main.tf` – Cleaned files, now containing only resource/module definitions.
* `docs/13_providers_refactoring.md` – This document.

### ✅ Outcome

* The project structure is cleaner and aligns perfectly with community and Enterprise standards for Terraform module layout.