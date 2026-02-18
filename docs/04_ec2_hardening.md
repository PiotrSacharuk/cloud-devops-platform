# Cloud / Terraform Learning


## EC2 Hardening (Security + Operability)


### 🎯 Goal


Harden the EC2 baseline and improve operability by introducing:


* Standardized resource tagging (`common_tags`)
* Enforced IMDSv2 on EC2 (token-required metadata)
* Encrypted root EBS volume
* IAM Role + Instance Profile for SSM Session Manager access


### 🧩 Scope


* One environment (`envs/dev`) using modules (`modules/network`, `modules/ec2`)
* EC2 bootstrapping extracted into a script and rendered via `templatefile()`
* Security hardening on EC2:
  * IMDSv2 required
  * Root volume encryption
* Operability hardening:
  * SSM Session Manager enabled via IAM role + instance profile


### 🛠 Key Steps


1. Introduced standardized tags in the environment layer:
   * `locals { common_tags = { Project, Environment, ManagedBy } }`
   * Passed `common_tags` into `module "network"` and `module "web"`
2. Extracted EC2 bootstrap from inline `user_data` into a dedicated script:
   * Added `bootstrap.sh` into `modules/ec2/`
   * Rendered it via:
     * `templatefile("${path.module}/bootstrap.sh", { environment = var.environment })`
   * Fixed a Terraform error caused by missing `bootstrap.sh` (the file must exist in the module source tree)
3. Enforced IMDSv2 on the EC2 instance:
   * Set `metadata_options { http_tokens = "required" }`
   * Verified token-based access to instance metadata (`169.254.169.254`) from inside the instance
4. Enforced EBS root volume encryption:
   * Configured `root_block_device { encrypted = true }`
5. Enabled SSM Session Manager access:
   * Added `aws_iam_role`, `aws_iam_instance_profile`, and `aws_iam_role_policy_attachment`
   * Verified the instance appears in SSM (`aws ssm describe-instance-information`)
   * Installed the Session Manager plugin locally and validated session connectivity
6. Installed the Session Manager plugin (client-side requirement):
   * Session Manager sessions started via AWS CLI require the Session Manager plugin on the client machine.
   * On Debian/Ubuntu the installation uses a `.deb` package and `dpkg`.

   Example (Ubuntu/Debian):

   ```bash
   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
     -o "session-manager-plugin.deb"

   sudo dpkg -i session-manager-plugin.deb


### 🧪 Validation


* `terraform plan` and `terraform apply` complete successfully
* EC2 boots reliably with the extracted bootstrap script
* IMDSv2 token flow works (metadata access requires a token)
* Root EBS volume encryption is enabled
* The instance registers in SSM and can be targeted for Session Manager sessions

### 🧪 Validation (SSM)

* Verified instance is registered in SSM:
  * `aws ssm describe-instance-information`
* Verified client-side plugin is installed (required for interactive sessions):
  * `session-manager-plugin --version`
* Started an interactive session:
  * `aws ssm start-session --target <instance-id>`

### 📄 Files Introduced / Updated


* `modules/ec2/bootstrap.sh` – extracted bootstrap logic (rendered by `templatefile()`)
* `modules/ec2/*.tf` – EC2 hardening: IMDSv2, EBS encryption, IAM profile attachment
* `envs/dev/main.tf` – `common_tags` + module wiring
* `docs/04_ec2_hardening.md` – this document


### ✅ Outcome


* Environment-aware Terraform setup with consistent tagging
* Hardened EC2 configuration (IMDSv2 + encrypted root volume)
* SSM Session Manager enabled via IAM role + instance profile (foundation for reducing/removing SSH later)


---