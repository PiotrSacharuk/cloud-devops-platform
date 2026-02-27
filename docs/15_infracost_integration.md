# Cloud / Terraform Learning

## Automated Cloud Cost Estimation (FinOps with Infracost)

### 🎯 Goal

Introduce "Shift-Left FinOps" by integrating Infracost into the CI/CD pipeline. This ensures that any infrastructure change proposed in a Pull Request is automatically evaluated for its cost impact before it is merged and deployed, safeguarding our AWS Free Tier budget.

### 🧩 Scope

* **CI/CD:** `.github/workflows/terraform-ci.yml`.
* **Tooling:** Infracost CLI & GitHub Actions.

### 🛠 Key Steps

1. **Authentication Configuration:**
   * Registered for a free Infracost API key.
   * Securely stored the key in GitHub Actions Secrets as `INFRACOST_API_KEY`.

2. **Pipeline Integration:**
   * Added an `infracost` job to the CI pipeline, explicitly configured to run only on `pull_request` events.
   * Utilized the `infracost/actions/setup` action to install the CLI tool.
   * Ran `infracost breakdown --path .` to scan all environment directories simultaneously and output a structured JSON report.

3. **Automated PR Comments:**
   * Utilized the `infracost/actions/comment` action to parse the JSON output and post a human-readable cost summary directly to the GitHub Pull Request.
   * Configured the `behavior: update` parameter so that subsequent pushes to the same PR update the existing comment rather than spamming the thread.

### 🧪 Validation

* **CI Execution:** The GitHub Action completes successfully, authenticating with the API and parsing the HCL files.
* **Developer Experience:** Opening a PR now generates an automated comment detailing the exact monthly cost of the infrastructure changes. Given our current architecture (t2.micro instances, free-tier EBS, DIY NAT), the expected cost impact is confirmed to be zero or minimal.

### 📄 Files Introduced / Updated

* `.github/workflows/terraform-ci.yml` – Added the `infracost` job.
* `docs/15_infracost_integration.md` – This document.

### ✅ Outcome

* Developers receive immediate financial feedback on their IaC code.
* The project enforces strict budget compliance at the earliest possible stage of the development lifecycle.