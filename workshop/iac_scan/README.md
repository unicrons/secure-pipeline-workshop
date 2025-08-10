# Infrastructure as Code (IaC) Security Scanning

This workshop module focuses on scanning Infrastructure as Code (IaC) configurations to identify security misconfigurations before infrastructure deployment.
 
## Why is IaC Security Important?
This is a key step in our shift-left security approach. In the same way we analyze our application code before deploying it, we should do the same with our infrastructure code.

IaC security scanning analyzes infrastructure definitions (Terraform, CloudFormation, Kubernetes YAML, etc.) to identify security misconfigurations, compliance violations, and best practice deviations before resources are provisioned.

This step has its limitations, as some issues can only be detected at runtime, but everything we can catch before the resources are deployed will be easier to fix and will provide a faster feedback loop.

## Common IaC Security Issues

Many of these issues are shared with the [Infrastructure Runtime Security](../runtime_infra_scan/) module.

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
- **Mis-scoped Load Balancers/Endpoints** – “internal” services accidentally reachable from the internet.

### Compliance & Governance
- **Insufficient Logging & Audit Trails** – generating blind spots for forensics and incident response.
- **Lack of Continuous Monitoring/Alerts** – misconfigurations persist until breach or audit.
- **Missing Resource Tagging** – untagged assets break cost, ownership, and policy enforcement.
- **Improper Backup Retention/Encryption** – backups stored unencrypted or outside mandated retention windows.

## Common IaC Recommendations

In addition to scanning for infrastructure security issues, we must also ensure the security of our IaC tools and processes. Consider these recommendations:

- **Remote State** - Use encrypted remote backends
- **State Locking** - Prevent concurrent modifications
- **Sensitive Variables** - Mark sensitive data appropriately
- **Provider Versions** - Pin provider versions
- **Module Security** - Vet third-party modules

## Tools Used in This Module

- [**Checkov**](https://github.com/bridgecrewio/checkov) - Static analysis tool for Infrastructure as Code security scanning
- [**Trivy**](https://github.com/aquasecurity/trivy) - Misconfiguration scanner for Infrastructure as Code
  - Also supports scanning filesystems, containers or repos, but we focus on IaC for this module


## Learning Objectives

By the end of this module, you will:
- Understand IaC security scanning principles
- Learn to identify common misconfigurations


## Security Checklist

### Access Control

- [ ] Enforce **least privilege** on all IAM roles, users, and service accounts
- [ ] Remove or refine **overly permissive policies** (wildcards, unused rights)
- [ ] Disable **default credentials** and enforce strong password requirements
- [ ] Require **MFA** for all administrative and sensitive accounts

### Encryption

- [ ] Enable **encryption at rest** for all storage, databases, and backups
- [ ] Require **TLS/SSL** for all data in transit (APIs, internal/external services)
- [ ] Regularly audit for **outdated cipher suites** or short encryption keys
- [ ] Encrypt **environment files** and state files containing sensitive data

### Secrets Management

- [ ] Remove all **hardcoded secrets** and credentials from IaC templates and code
- [ ] Store secrets in a **dedicated vault** or secret manager
- [ ] Rotate and revoke secrets according to a documented schedule
- [ ] Ensure CI/CD pipelines and scripts never expose secrets in logs

### Network Security

- [ ] Limit public exposure by closing all unnecessary **Security Groups** (no 0.0.0.0/0)
- [ ] Place resources in **private subnets** unless public access is specifically required
- [ ] Implement **network segmentation** with firewalls or network policies
- [ ] Restrict **east–west traffic** (internal workloads) to the minimum necessary

### Monitoring & Logging

- [ ] Enable **comprehensive logging** (CloudTrail, audit logs, API logs)
- [ ] Configure **continuous monitoring and alerting** for abnormal activity
- [ ] Regularly review logs for signs of **unauthorized access or configuration drift**
- [ ] Ensure logs are retained and protected in accordance with policy

### Backup & Recovery

- [ ] Implement regular **backup schedules** for databases, storage, and state files
- [ ] **Encrypt all backups** and store copies in geographically separate locations
- [ ] Test **disaster recovery procedures** periodically
- [ ] Set **retention policies** that comply with business and regulatory requirements

### Governance & Compliance

- [ ] Tag all resources for **cost tracking, ownership, and lifecycle management**
- [ ] Enable **automated checks** for regulatory compliance (GDPR, HIPAA, PCI-DSS)
- [ ] Maintain up-to-date **audit trails** and documentation
- [ ] Conduct regular **security reviews** and remediation of IaC configurations

### Supply Chain & Container Security

- [ ] Use only **trusted IaC modules** and dependencies—verify source and integrity
- [ ] Scan all container and base images for **known vulnerabilities**
- [ ] Restrict use of **public image registries** unless approved and scanned
- [ ] Set **resource limits** and avoid privileged containers in orchestration

### Change and State Management

- [ ] Store state files in a **remote, encrypted backend** with locked access
- [ ] Enable **state locking** to prevent concurrent modifications
- [ ] Enforce **code review and approvals** before IaC changes are applied
- [ ] Detect and remediate **configuration drift** between infrastructure and code


## References
- [Infrastructure as Code (IaC) Security: 10 Best Practices](https://spacelift.io/blog/infrastructure-as-code-iac-security)
- [The Hidden Risk in Your Cloud Stack - CSA Blog](https://checkred.com/resources/blog/the-hidden-risk-in-your-cloud-stack-how-overlooked-aws-resources-become-entry-points-for-hackers/) <!-- trufflehog:ignore -->
- [Terraform Plan RCE](https://alex.kaskaso.li/post/terraform-plan-rce): A terraform plan is not as passive as you may think. If you run production plans on PRs you could be opening a path to bypassing branch protections and any expected process you have for production access.

### Other Tools
- [DataDog/terraform-provider-terrapwner](https://github.com/DataDog/terraform-provider-terrapwner): Terrapwner is a security-focused Terraform provider designed for testing and validating CI/CD pipelines.
