# Cloud / Terraform Learning

## Private Networking & DIY NAT Instance

### 🎯 Goal

Prepare the network infrastructure to host application servers securely in a private subnet. To maintain a strict zero-cost (AWS Free Tier) approach, we will bypass the expensive AWS Managed NAT Gateway by provisioning a DIY NAT Instance using a Free Tier eligible EC2 instance.

### 🧩 Scope

* **Module:** `modules/network`
* **Components:** Private Subnet, Route Table, Security Group, EC2 Instance (NAT), IAM/Security baselines.

### 🛠 Key Steps

1. **Private Subnet Creation:**
   * Defined `aws_subnet.private` with `map_public_ip_on_launch = false`.
   * Created a dedicated `aws_route_table` for the private subnet.

2. **DIY NAT Instance Provisioning:**
   * Deployed an Amazon Linux EC2 instance into the **Public Subnet**.
   * Disabled `source_dest_check` on the instance (crucial for allowing the instance to forward traffic not originally destined for its own IP).
   * Attached a strict Security Group allowing inbound HTTP/HTTPS from the Private Subnet CIDR and outbound HTTP/HTTPS to the internet.

3. **OS-Level Routing (user_data):**
   * Configured the NAT instance as a router using a bootstrap script:
     * Enabled IPv4 forwarding via `sysctl`.
     * Configured `iptables` to masquerade (NAT) outbound traffic originating from the private network.

4. **VPC Routing Configuration:**
   * Added a route (`aws_route`) to the private route table directing all internet-bound traffic (`0.0.0.0/0`) to the NAT instance's Network Interface.

5. **Security Hardening (DevSecOps loop):**
   * Addressed Trivy CI failures during implementation by enforcing root volume encryption (`root_block_device { encrypted = true }`) and IMDSv2 (`metadata_options { http_tokens = "required" }`) on the newly created NAT instance.

6. **Module Interface Updates:**
   * Exported `private_subnet_id` in `outputs.tf` so other modules can place resources inside the secure boundary.

### 🧪 Validation

* **CI/CD:** The pipeline passed all TFLint and Trivy checks after the security baseline was applied to the NAT instance.
* **Infrastructure State:** The network module now successfully encapsulates both public (bastion/NAT/load balancers) and private (application servers/databases) routing logic.

### 📄 Files Introduced / Updated

* `modules/network/variables.tf` – Added `private_cidr`.
* `modules/network/main.tf` – Added private subnet, route table, NAT instance, and NAT routing.
* `modules/network/outputs.tf` – Exported `private_subnet_id`.

### ✅ Outcome

* The architectural foundation for deploying private, internet-isolated EC2 instances is complete.
* We successfully implemented a highly educational and cost-effective NAT solution that strictly adheres to the AWS Free Tier budget.