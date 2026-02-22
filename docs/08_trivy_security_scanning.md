# Cloud / Terraform Learning

## DevSecOps: IaC Security Scanning with Trivy

### 🎯 Goal

Introduce Security into the CI/CD pipeline (DevSecOps) by integrating [Trivy](https://aquasecurity.github.io/trivy/), a comprehensive security scanner. The goal is to automatically detect AWS misconfigurations, overly permissive security groups, and other security flaws in our Terraform code before they are deployed, while strictly operating within the AWS Free Tier budget.

### 🧩 Scope

* **Repository:** All Terraform files (`envs/` and `modules/`).
* **CI Platform:** GitHub Actions (`.github/workflows/terraform-ci.yml`).
* **Tooling:** Aqua Security Trivy (Action `aquasecurity/trivy-action`).

### 🛠 Key Steps

1. **Pipeline Integration:**
   * Added the `trivy` job to the CI workflow, positioned after `tflint` and before `validate`.
   * Configured the action to run in `config` (IaC) mode, scanning for `HIGH` and `CRITICAL` severity issues.
   * Enforced pipeline failure (`exit-code: '1'`) if unauthorized vulnerabilities are detected.

2. **Reporting Updates:**
   * Updated the final `report` job in GitHub Actions to collect and display the Trivy execution status in the automated Pull Request comment.

3. **Handling Free Tier Constraints (Risk Acceptance):**
   * Trivy naturally enforces Enterprise-grade security practices, some of which incur unavoidable AWS costs (e.g., Managed NAT Gateways, VPC Flow Logs, paid KMS keys).
   * Created a `.trivyignore` file to formally accept and bypass specific risks to maintain a zero-cost architecture:
     * `AVD-AWS-0178` (VPC Flow Logs).
     * `AVD-AWS-0026` (Customer Managed KMS Keys for EBS).
     * `AVD-AWS-0028` (IMDSv2 hop limit restrictions).
     * `AVD-AWS-0104` (Unrestricted egress - scheduled for future port-level restriction).
     * `AVD-AWS-0164` (Public IPs on subnets - scheduled for future NAT Instance architecture).

### 🧪 Validation

* **Security Interception:** Verified that Trivy successfully identifies overly permissive Security Group egress rules and public subnets, successfully failing the build when undocumented.
* **Ignore Mechanism:** Confirmed that documenting risks in `.trivyignore` allows the pipeline to pass while maintaining an audit trail of accepted risks.
* **CI Report:** The PR comment correctly outputs the Trivy stage result (e.g., `success`, `failure`).

### 📄 Files Introduced / Updated

* `.trivyignore` – List of accepted security risks (budget-driven exceptions).
* `.github/workflows/terraform-ci.yml` – Added the `trivy` scanning job and updated the PR report logic.

### ✅ Outcome

* The CI pipeline now has a strong DevSecOps gate, preventing accidental introduction of critical security vulnerabilities.
* The project maintains a clean audit trail of accepted risks versus enforced security controls.
* We have identified clear technical debt (egress rules and subnet architecture) to be resolved in future iterations without breaking the AWS Free Tier constraints.