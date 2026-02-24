# Cloud / Terraform Learning

## Private Subnet Migration & FinOps Guardrails

### 🎯 Goal

Enhance architectural security by migrating application servers (EC2) into an isolated private subnet with no direct inbound internet access. Simultaneously, resolve soft limit issues (vCPU) and optimize costs by ensuring all resources comfortably fit within the AWS Free Tier. Finally, eliminate the `AWS-0164` security vulnerability from the codebase.

### 🧩 Scope

* **Module:** `modules/network` (Subnets and IP assignments).
* **Environments:** `envs/dev`, `envs/staging`, `envs/prod` (Module inputs).
* **Security Tooling:** `.trivyignore`.

### 🛠 Key Steps

1. **FinOps & Compute Limits Remediation:**
   * Encountered an AWS `VcpuLimitExceeded` error (max 8 vCPUs allowed by default for new accounts).
   * **Action:** Changed the NAT instance type from `t3.micro` (2 vCPU) to `t2.micro` (1 vCPU). This not only bypassed the soft limit but also guarantees strict compliance with the AWS Free Tier (which covers `t2.micro` compute time).
   * **Action:** Destroyed unused `staging` and `prod` environments temporarily to conserve the 750-hour monthly Free Tier quota.

2. **Remediating Public IP Security Risk (AWS-0164):**
   * Modified the public subnet in `modules/network/main.tf` to set `map_public_ip_on_launch = false`. Auto-assigning public IPs to everything in a subnet is an anti-pattern.
   * Explicitly added `associate_public_ip_address = true` solely to the NAT instance, as it is the only resource that natively requires internet-facing capabilities.

3. **Application Server Migration:**
   * Updated the `module "web"` block in the environment definitions (`envs/*/main.tf`).
   * Replaced the public subnet reference with `module.network.private_subnet_id`.

4. **Trivy Risk Cleanup:**
   * Because the application instances are now private and the subnets no longer automatically assign public IPs, the previously documented exception `AVD-AWS-0164` in `.trivyignore` was removed.

### 🧪 Validation

* **Deployment:** `terraform apply` succeeded without vCPU limit errors.
* **Security Scanner:** Trivy executed successfully in CI without requiring the `AWS-0164` exception.
* **Connectivity Testing (The Ultimate Proof):**
  * Identified the private web instance ID.
  * Connected to the instance via AWS Systems Manager (SSM) without an SSH key or public IP.
  * Executed `curl http://localhost` locally on the instance, successfully returning the Nginx welcome page. This proves that the `bootstrap.sh` script successfully reached the internet through the DIY NAT instance to install packages.
  * Used SSM Port Forwarding (`AWS-StartPortForwardingSession`) to tunnel port 80 to the local developer machine, allowing browser-based verification.

### 📄 Files Introduced / Updated

* `modules/network/main.tf` – Updated public IP mappings and NAT instance sizing.
* `envs/*/main.tf` – Moved web instances to the private subnet.
* `.trivyignore` – Removed the resolved `AVD-AWS-0164` exception.
* `docs/11_private_ec2_migration.md` – This document.

### ✅ Outcome

* The architecture now reflects Enterprise standard practices: application servers are completely hidden in a private tier, while a carefully controlled Bastion/NAT tier handles internet connectivity.
* We maintained a zero-cost footprint while drastically improving the security posture.