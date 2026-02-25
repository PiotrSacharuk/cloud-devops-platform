# Cloud / Terraform Learning

## Backend Security Hardening (S3)

### 🎯 Goal

Secure the "Crown Jewels" of the Infrastructure as Code setup: the Terraform state file. The state file can contain sensitive data (secrets, tokens, architecture maps) in plaintext. We must ensure it is encrypted, version-controlled, and strictly isolated from public access.

### 🧩 Scope

* **Environment:** `envs/global`
* **Services:** AWS S3 (Backend Bucket).

### 🛠 Key Steps

Instead of recreating the foundational S3 bucket (which presents a chicken-and-egg problem for Terraform state), we applied security-specific resources directly to the existing bucket name from within the `global` workspace.

1. **Public Access Block:**
   * Utilized `aws_s3_bucket_public_access_block` to set all four block configuration flags to `true` (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`).
   * This guarantees that even if a misconfigured policy is applied in the future, AWS will reject any public access requests.

2. **Bucket Versioning:**
   * Enabled `aws_s3_bucket_versioning`.
   * **Why:** If a rogue `terraform apply` or `destroy` corrupts the state file, we can navigate to the AWS Console and restore the previous version of `terraform.tfstate`, instantly recovering the infrastructure mapping.

3. **Encryption at Rest:**
   * Enforced `aws_s3_bucket_server_side_encryption_configuration` utilizing the `AES256` algorithm (Amazon S3-managed keys / SSE-S3).
   * **Why SSE-S3:** It provides compliance-level at-rest encryption while remaining completely free, maintaining our strict zero-cost architectural constraints (avoiding the $1/month charge associated with AWS KMS CMKs).

### 🧪 Validation

* **CI/CD:** Pipeline successfully validated the additions to the `global` environment.
* **Security Posture:** The implementation aligns perfectly with `trivy` and general DevSecOps best practices for remote state management.

### 📄 Files Introduced / Updated

* `envs/global/main.tf` – Added S3 security resources.
* `docs/14_backend_security_hardening.md` – This document.

### ✅ Outcome

* The remote state backend is now Enterprise-grade secure. It is resilient to data loss (versioning) and data theft (encryption + public access blocks).