# Cloud / Terraform Learning

## Network Hardening & Security Risk Acceptance

### 🎯 Goal

Enhance the security posture of the infrastructure by restricting outbound (egress) network traffic to the absolute minimum required ports, while learning how to formally manage and document "Accepted Risks" in DevSecOps tooling (Trivy) due to budget constraints (AWS Free Tier)[cite: 148].

### 🧩 Scope

* **Shared Modules:** `modules/network/main.tf` (Security Groups).
* **Security Tooling:** `.trivyignore` at the repository root.

### 🛠 Key Steps

1. **Restricting Egress Traffic (Hardening):**
   * Removed the default "allow all" outbound rule (`protocol = "-1"`, `from_port = 0`, `to_port = 0`) from the web Security Group.
   * Replaced it with two explicit rules:
     * **HTTP (Port 80):** Required for fetching unencrypted OS packages during the `bootstrap.sh` phase.
     * **HTTPS (Port 443):** Required for secure OS updates and establishing a connection with the AWS Systems Manager (SSM) control plane.

2. **Managing Trivy Scanner Exceptions:**
   * **The Challenge:** Even with restricted ports, using `cidr_blocks = ["0.0.0.0/0"]` triggers Trivy's `CRITICAL` alerts (`AVD-AWS-0104` for egress and `AVD-AWS-0107` for ingress). Trivy expects traffic to be routed through an Egress Proxy or AWS VPC Endpoints, and inbound traffic to come through a Load Balancer.
   * **The Reality:** VPC Endpoints, NAT Gateways, and Application Load Balancers incur significant hourly charges, breaking the zero-cost lab requirement. Additionally, AWS service IPs change dynamically, making static IP whitelisting impossible.
   * **The Solution (Risk Acceptance):** Added both `AVD-AWS-0104` and `AVD-AWS-0107` to the `.trivyignore` file with explicit documentation explaining *why* the risk is accepted (Free Tier limitations).

### 🧪 Validation

* **Security Posture:** Outbound traffic is now strictly limited to web and secure web protocols, preventing compromised instances from establishing arbitrary outbound connections (e.g., reverse shells on non-standard ports).
* **DevSecOps Flow:** Running `trivy config .` locally returns a clean report (exit code 0), proving that our explicitly documented ignores are working correctly.
* **CI/CD:** The GitHub Actions pipeline correctly respects the `.trivyignore` file and allows the deployment to proceed.

### 📄 Files Introduced / Updated

* `modules/network/main.tf` – Replaced full egress with strict HTTP/HTTPS rules.
* `.trivyignore` – Added context-aware exceptions for `AVD-AWS-0104` and `AVD-AWS-0107`.
* `docs/09_network_hardening.md` – This document.

### ✅ Outcome

* Network attack surface is significantly reduced.
* Demonstrated a mature DevSecOps workflow: evaluating a security scanner's alert, understanding the business/architectural context, applying a partial fix (port restriction), and formally documenting the remaining accepted risk (IP range).