# Infrastructure as Code (IaC) Security Scan

> ⏱ ~15 min · 📍 Module 5 of 7
>
> [1](../pipeline_scan/) ▸ [2](../code_scan/) ▸ [3](../secrets_scan/) ▸ [4](../container_scan/) ▸ **5** ▸ [6](../runtime_infra_scan/) ▸ [7](../ai_review/)

This workshop module focuses on scanning Infrastructure as Code (IaC) configurations to identify security misconfigurations before infrastructure deployment.

## Why is IaC Security Important?
This is a key step in our shift-left security approach. Just as we analyze our application code before deploying, we should do the same with our infrastructure code.

IaC security scanning analyzes infrastructure definitions (Terraform, CloudFormation, Kubernetes YAML, etc.) to identify security misconfigurations, compliance violations, and best practice deviations before resources are provisioned.

Some issues can only be detected at runtime — see the [Runtime Infrastructure Scan](../runtime_infra_scan/) module — but everything caught at this stage is cheaper to fix.

## Common IaC Security Issues

> The catalog of issues here overlaps heavily with the [Runtime Infrastructure Scan](../runtime_infra_scan/) module. The list below is the IaC-side view; the runtime module covers the same categories from a deployed-resources perspective plus drift.

### Access Control
- **Overly Permissive IAM Policies** – wildcard privileges and never-used rights that violate least-privilege.
- **Publicly Accessible Resources** – buckets, APIs, or DBs left open to the internet.
- **Missing Authentication Controls** – services deployed with no auth/MFA, allowing unauthenticated calls.
- **Default or Weak Credentials** – reused passwords and default logins vulnerable to brute-force.

### Encryption
- **Unencrypted Storage at Rest** – plaintext data in S3, EBS, RDS, state files.
- **Unencrypted Backups & Snapshots** – archives stored without server- or client-side encryption.
- **Missing TLS/In-Transit Encryption** – APIs or internal links still on plain HTTP or legacy protocols.
- **Weak or Outdated Cipher Suites** – obsolete algorithms or short keys still in use.

### Network Security
- **Open Security Groups (0.0.0.0/0)** – internet-wide access to SSH, RDP, or high-risk custom ports.
- **Public-Subnet Exposure** – instances or containers with public IPs sitting in public subnets.
- **Mis-scoped Load Balancers/Endpoints** – "internal" services accidentally reachable from the internet.

### IaC Tooling & Process
- **Unencrypted Remote State** – Terraform/Pulumi state files holding sensitive data without server-side encryption or proper access control.
- **Missing State Locking** – concurrent runs corrupting state.
- **Unpinned Providers / Untrusted Modules** – third-party modules pulled by floating refs, opening a supply-chain path.

### Compliance & Governance
- **Insufficient Logging & Audit Trails** – generating blind spots for forensics and incident response.
- **Missing Resource Tagging** – untagged assets break cost, ownership, and policy enforcement.

## Tools Used in This Module

| Tool | What it does | Notes |
|---|---|---|
| [**Checkov**](https://github.com/bridgecrewio/checkov) | Static analysis tool for IaC security scanning | Terraform, CloudFormation, Kubernetes, ARM and more |
| [**Trivy**](https://github.com/aquasecurity/trivy) | Misconfiguration scanner for IaC | Also scans containers/filesystems/repos; this module focuses on IaC |

## Learning Objectives

By the end of this module, you will:
- Understand IaC security scanning principles
- Learn to identify common misconfigurations

## Security Checklist

- [ ] Enforce **least privilege** on IAM — no wildcard actions or unused permissions
- [ ] No **0.0.0.0/0** ingress on sensitive ports; resources in private subnets unless public is required
- [ ] **Encryption at rest and in transit** enabled for all storage, databases, backups and APIs
- [ ] No **hardcoded secrets** in IaC — credentials live in a dedicated secret manager
- [ ] **Logging and audit trails** enabled (CloudTrail, audit logs) with sane retention
- [ ] **Resources tagged** for ownership, cost, and lifecycle management
- [ ] **State files** stored in a remote, encrypted backend with locking enabled
- [ ] **Modules and providers** pinned by SHA/version; third-party sources vetted
- [ ] **Code review and approvals** required before IaC changes are applied

## References
- [Infrastructure as Code (IaC) Security: 10 Best Practices](https://spacelift.io/blog/infrastructure-as-code-iac-security)
- [The Hidden Risk in Your Cloud Stack - CSA Blog](https://checkred.com/resources/blog/the-hidden-risk-in-your-cloud-stack-how-overlooked-aws-resources-become-entry-points-for-hackers/) <!-- trufflehog:ignore -->
- [Terraform Plan RCE](https://alex.kaskaso.li/post/terraform-plan-rce): A terraform plan is not as passive as you may think. If you run production plans on PRs you could be opening a path to bypassing branch protections and any expected process you have for production access.

### Other Tools
- [DataDog/terraform-provider-terrapwner](https://github.com/DataDog/terraform-provider-terrapwner): Terrapwner is a security-focused Terraform provider designed for testing and validating CI/CD pipelines.

## Solutions (spoilers — open only when stuck)

> The bait is a single misconfigured ingress rule in `infra/main.tf`. Both scanners (Checkov and Trivy IaC) flag the same line range. One fix clears both.

<details>
<summary><b>Checkov</b> — <code>CKV_AWS_24</code> at <code>infra/main.tf:120-126</code></summary>

**What Checkov flagged**: `aws_security_group.ecs_tasks` has an ingress rule with `description = "HTTP from ALB"` but `from_port = 22 / to_port = 22` and `cidr_blocks = ["0.0.0.0/0"]` — i.e. SSH open to the whole internet. Classic copy-paste/typo bait.

**Reading the output**: Checkov (with `quiet: true`) prints only failed checks plus a summary like `Passed checks: 18, Failed checks: 1`. The output names the rule, the resource, the file, the line range, and quotes the offending lines. Best output in the module.

**Fix** — close SSH-from-anywhere and reopen on the actual app port, restricted to the VPC CIDR. The SRE note above the resource literally hands you the data source you need (`data.aws_vpc.existing.cidr_block`):

```diff
   ingress {
-    description = "HTTP from ALB"
-    from_port   = 22
-    to_port     = 22
+    description = "HTTP from ALB (workshop)"
+    from_port   = 3000
+    to_port     = 3000
     protocol    = "tcp"
-    cidr_blocks = ["0.0.0.0/0"]
+    cidr_blocks = [data.aws_vpc.existing.cidr_block]
   }
```

</details>

<details>
<summary><b>Trivy IaC</b> — <code>AVD-AWS-0107</code> on the same block</summary>

**What Trivy IaC flagged**: same ingress rule (port 22 from `0.0.0.0/0`). Trivy's rule ID is `AVD-AWS-0107`.

**Reading the output**: the snippet's `Summarize findings` step parses the SARIF and prints `ruleId | message | path:line` directly to the job log — no GHAS required. The SARIF is also uploaded to the GitHub *Code Scanning* tab if your fork has GHAS enabled.

**Fix** — identical to the Checkov fix above.

</details>