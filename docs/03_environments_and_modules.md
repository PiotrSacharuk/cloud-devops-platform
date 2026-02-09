# Cloud / Terraform Learning

## Problem Definition & Local Infrastructure

### 🎯 Goal

Set up a minimal AWS infrastructure using Terraform to validate:

* AWS account access
* Terraform workflow (init / plan / apply)
* EC2 + networking basics
* Ability to expose a simple web service

### 🧩 Scope

* One VPC
* One public subnet
* Internet Gateway + route table
* Security Group (SSH + HTTP)
* One EC2 instance (Free Tier)
* Nginx running via `user_data`

### 🛠 Key Steps

1. Installed and configured:

   * AWS account
   * AWS CLI (Snap)
   * Terraform
2. Configured AWS credentials (`aws configure`)
3. Created Terraform configuration:

   * `provider "aws"`
   * `aws_vpc`, `aws_subnet`
   * `aws_internet_gateway`, `aws_route_table`
   * `aws_security_group`
   * `aws_instance`
4. Used **dynamic AMI lookup** with `data "aws_ami"`
5. Fixed Free Tier issue by switching to eligible instance type
6. Verified deployment:

   * `terraform apply`
   * `curl <public_ip>` → Nginx welcome page

### ✅ Outcome

* Fully working EC2 instance
* HTTP accessible from the internet
* Terraform local state created

---

## State Management & Git Hygiene

### 🎯 Goal

Move from **local-only Terraform** to **team-ready setup** with:

* Remote state
* State locking
* Proper Git practices

### 🧱 Remote State Design

* **S3** → Terraform state storage
* **DynamoDB** → state locking

### 📄 Files Introduced

* `backend.tf` – Terraform backend configuration
* `.gitignore` – exclude local artifacts
* `.terraform.lock.hcl` – provider dependency lock (committed)

### 🔐 Backend Configuration (S3 + DynamoDB)

* Backend defined in `terraform { backend "s3" {} }`
* State key versioned per project/day
* Encryption enabled

### 🔁 Migration

* Used:

  ```bash
  terraform init -migrate-state
  ```
* Migrated local `terraform.tfstate` → S3

### 🧪 Validation

* State locking confirmed via concurrent `terraform apply`
* Terraform correctly blocks parallel writes

### 📦 Git Commit Rules

**Committed:**

* `*.tf`
* `backend.tf`
* `.terraform.lock.hcl`
* `*.md`

**Ignored:**

* `.terraform/`
* `terraform.tfstate`
* `terraform.tfstate.backup`

### ✅ Outcome

* Remote, encrypted, locked Terraform state
* Repo safe for collaboration
* Clean separation between code and runtime artifacts

---