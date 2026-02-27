# Cloud / Terraform Learning

## Compute Security: IAM Instance Profiles

### 🎯 Goal

Implement the principle of least privilege and eliminate the need for static credentials (like AWS Access Keys) on compute instances. By assigning an IAM Identity directly to the EC2 instance, we allow it to securely interact with other AWS services (like SSM) using automatically rotated, short-lived credentials.

### 🧩 Scope

* **Module:** `modules/ec2`
* **Services:** AWS IAM (Roles, Policies, Instance Profiles), AWS EC2.

### 🛠 Key Steps

1. **Defining the Trust Relationship:**
   * Created an `aws_iam_role` resource specifically for EC2.
   * Configured the `assume_role_policy` to explicitly trust `ec2.amazonaws.com`, allowing the compute service to assume this identity.

2. **Granting Specific Permissions:**
   * Used `aws_iam_role_policy_attachment` to attach the `AmazonSSMManagedInstanceCore` policy.
   * This managed policy contains the exact permissions required for the SSM Agent (pre-installed on Amazon Linux 2023) to register with the Systems Manager control plane, enabling secure shell access without SSH keys or public IPs.

3. **Binding Identity to Compute:**
   * Created an `aws_iam_instance_profile` to act as a container for the IAM role.
   * Updated the `aws_instance` resource to include the `iam_instance_profile` argument, linking the deployed server to its new identity.

### 🧪 Validation

* **Security Scanner:** Trivy ensures no hardcoded secrets or overly permissive wildcard (`*`) policies are introduced.
* **Cost Impact:** IAM Roles and Policies are a free feature of AWS IAM. Infracost confirms zero cost impact.

### 📄 Files Introduced / Updated

* `modules/ec2/iam.tf` – Defined IAM roles, attachments, and profiles.
* `modules/ec2/main.tf` – Attached the profile to the EC2 instance.
* `docs/16_iam_instance_profiles.md` – This document.

### ✅ Outcome

* The application instances are now cryptographically authenticated to the AWS API.
* This establishes a highly scalable pattern: if the application needs to read from S3 or fetch a secret from Secrets Manager in the future, we simply attach a new policy to this existing role.