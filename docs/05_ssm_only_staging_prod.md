# Cloud / Terraform Learning

## Environment Access Model (SSM-only for Staging/Prod, SSH for Dev)

### 🎯 Goal

Harden environment access by introducing a clear access model: **SSM-only** for `staging` and `prod`, while keeping **SSH enabled** in `dev` for debugging and fast iteration.

This day focuses on removing inbound SSH exposure (port 22) where it should not exist, and ensuring we can still operate instances using AWS Systems Manager Session Manager.

### 🧩 Scope

* Three environments in one AWS account:
  * `envs/dev`
  * `envs/staging`
  * `envs/prod`
* Shared Terraform modules:
  * `modules/network`
  * `modules/ec2`
* Remote state:
  * Same S3 backend bucket + DynamoDB lock table
  * Separate **S3 state keys per environment** (e.g. `cloud-devops-platform/<env>/terraform.tfstate`).
* Access model per environment:
  * `staging` + `prod`: **SSM-only**, no SSH key pair, no inbound 22.
  * `dev`: SSH allowed from a single trusted CIDR (`allowed_ssh_cidr`), plus HTTP 80 for the demo web service.


### 🛠 Key Steps

1. Standardized remote state key naming (per environment):
   * Updated `backend.tf` to use environment-scoped keys (examples):
     * `cloud-devops-platform/dev/terraform.tfstate`
     * `cloud-devops-platform/staging/terraform.tfstate`
     * `cloud-devops-platform/prod/terraform.tfstate`
   * Reinitialized backends with:
     * `terraform init -reconfigure`

2. Introduced an environment-driven SSH toggle (`enable_ssh`):
   * Goal: the same modules can support:
     * SSH-enabled environments (dev)
     * SSH-disabled environments (staging/prod)

3. Network hardening (port 22 control) in `modules/network`:
   * Added conditional Security Group ingress rule for SSH (22) behind `enable_ssh`.
   * Result:
     * `staging` and `prod` security groups expose **only** HTTP 80.
     * `dev` security group exposes HTTP 80 and SSH 22 (restricted by CIDR).

4. EC2 access hardening in `modules/ec2`:
   * Made EC2 Key Pair creation conditional (`enable_ssh`).
   * When `enable_ssh=false`:
     * Do not create `aws_key_pair`.
     * Ensure `aws_instance.key_name` is effectively unset (null), so the instance has no key pair attached.

5. Environment wiring:
   * `envs/prod`:
     * `enable_ssh = false` in both `module "network"` and `module "web"`.
     * Removed module arguments and tfvars for `key_name` and `public_key_path` (SSM-only by configuration).
   * `envs/staging`:
     * Same as prod (SSM-only).
   * `envs/dev`:
     * Kept SSH enabled:
       * `module "web"` uses `enable_ssh=true` + key pair inputs.
       * `module "network"` uses `enable_ssh=true` to actually open port 22 (this was the missing piece initially).

6. Git hygiene (plan artifacts):
   * Did not commit binary plan outputs (`tfplan` / `*.tfplan`).
   * Added ignore rules:
     * `tfplan`
     * `*.tfplan`


### 🧪 Validation

* Terraform workflow per environment:
  * `terraform fmt -recursive`
  * `terraform validate`
  * `terraform plan`
  * `terraform apply`
  * `terraform destroy` (lab cleanup).

* HTTP check (all envs):
  ```bash
  IP=$(terraform output -raw web_public_ip)
  curl -i http://$IP
  ```

* SSH check (dev only):
  ```bash
  ssh -i ~/.ssh/<dev-private-key> ec2-user@$IP
  ```

* SSH negative test (staging/prod):
  * Expected: connection fails because port 22 is not open and there is no key pair attached.


### 🧪 Validation (SSM)

* Find instance id by Name tag:
  ```bash
  IID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=<staging-web|prod-web>" "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" --output text)
  echo "$IID"
  ```

* Start interactive session:

  ```bash
  aws ssm start-session --target "$IID"
  ```

  The --target argument is required.

* Confirm the instance has no key pair attached (staging/prod):

  ```bash
  aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=<staging-web|prod-web>" "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].KeyName" --output text
  ```
  Expected: empty / None.

## Files Introduced / Updated

- envs/staging/* – environment configuration, separate backend key, SSM-only wiring.
- envs/prod/* – environment configuration, separate backend key, SSM-only wiring.
- envs/dev/* – kept SSH enabled; ensured modules/network receives enable_ssh=true.
- modules/network/*.tf – conditional SSH ingress (port 22) controlled by enable_ssh.
- modules/ec2/*.tf – conditional Key Pair creation; key_name unset when SSH disabled.
- .gitignore – ignore Terraform plan artifacts (tfplan, *.tfplan).
- docs/05_ssm_only_staging_prod_dev_ssh.md – this document.

## Outcome

staging and prod operate with SSM-only access:

- No inbound SSH (22) in Security Groups.
- No EC2 key pair attached to instances.

dev remains developer-friendly:

- SSH is enabled and restricted to a trusted /32 CIDR.

State management is cleaner:

- Each environment has its own remote state key in S3, with locking in DynamoDB.
