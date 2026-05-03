# Runtime Infrastructure Scan

> ⏱ ~10 min (read-only) / ~25 min (live AWS) · 📍 Module 6 of 7
>
> [1](../pipeline_scan/) ▸ [2](../code_scan/) ▸ [3](../secrets_scan/) ▸ [4](../container_scan/) ▸ [5](../iac_scan/) ▸ **6** ▸ [7](../ai_review/)

> [!IMPORTANT]
> This module needs **a live AWS account** (IAM role + GitHub OIDC trust). Without it,
> leave the placeholder as-is — the rest of the workshop works fine. To enable it,
> see [Running this module](#running-this-module) below.

This workshop module focuses on scanning the deployed (runtime) infrastructure for vulnerabilities and misconfigurations that may not be detectable through static analysis of code or configuration files.

## Why is Runtime Infrastructure Scanning Important?

While IaC scans catch many issues pre-deployment, some vulnerabilities or misconfigurations only manifest once resources are live — manual changes, dynamic variables, complex cross-service interactions, or even a provider bug deploying resources in unintended ways.

## Common Runtime Infrastructure Issues

The catalog of categories (access control, encryption, network, compliance) is the same as the [IaC Security Scan](../iac_scan/#common-iac-security-issues) module — see that list there. The key addition at runtime is:

- **Drift** – resources not (or no longer) managed by IaC: manual console changes, hotfixes, ad-hoc deployments. Drift is invisible to static IaC scans by definition.

## Tools Used in This Module

| Tool | What it does | Notes |
|---|---|---|
| [**Prowler**](https://github.com/prowler-cloud/prowler) | Security best-practice assessments for cloud providers | AWS, Azure, GCP, M365, GitHub and more; we focus on the assessment role |
| [**Steampipe**](https://github.com/turbot/steampipe) | SQL-based cloud analysis and compliance | Query cloud resources as SQL tables; multi-provider |

## Learning Objectives

By the end of this module, you will:
- Understand the importance of runtime infrastructure scanning
- Learn to use automated tools to assess live cloud environments

## Security Checklist

- [ ] All systems and services are up to date with security patches
- [ ] No unnecessary open ports or services
- [ ] Strong authentication and access controls in place
- [ ] Security groups/firewalls follow least privilege
- [ ] Encryption enabled for data at rest and in transit
- [ ] No sensitive resources publicly exposed
- [ ] Monitoring and logging enabled for all critical resources
- [ ] Regular runtime scans scheduled and reviewed

## Running this module

> Unlike the other modules, this one has **no planted bait** to fix. Runtime scans target a *live* AWS account, so the findings depend entirely on whose infrastructure the job assumes into. During the workshop the role points at the maintainers' sandbox account, where you have no permissions to remediate anything — the job is expected to pass green even if Prowler reports findings (note the `-z` flag in the snippet, which suppresses the failing exit code on findings so the pipeline doesn't block on issues you can't fix).

<details>
<summary><b>Prowler</b> — what to expect during the workshop</summary>

**What you'll see**: the `Run Prowler` step assumes the workshop AWS role and scans the `iam` and `s3` services. The HTML report is uploaded as the `prowler-html-report` artifact — download it from the run summary to browse findings grouped by service, severity, and check ID.

**Why nothing is failing**: `prowler aws ... -z` (the "zero exit code" flag) is intentional here. Without it, *any* finding would fail the job, and you'd be staring at issues in someone else's account with no way to fix them. The point of this step in the workshop is to **wire the integration** (OIDC auth, role assumption, artifact upload), not to remediate.

**Reading the report**: open `prowler-html-report/*.html` and look for high-severity items in `iam` (overly permissive policies, unused credentials, root usage) and `s3` (public buckets, unencrypted storage, missing logging). These are the categories you'd triage first on a real account.

</details>

<details>
<summary><b>Steampipe + Powerpipe</b> — what to expect during the workshop</summary>

**What you'll see**: the snippet starts a local `steampipe service`, then runs the [`steampipe-mod-aws-compliance`](https://github.com/turbot/steampipe-mod-aws-compliance) `cis_v150` benchmark via Powerpipe against the assumed AWS role. The HTML report is uploaded as the `powerpipe-html-report` artifact — download it from the run summary to browse the CIS v1.5.0 benchmark results.

**Why pick Steampipe over Prowler**: Steampipe exposes cloud resources as **SQL tables** (`select * from aws_iam_user where mfa_enabled = false;`), so you can write ad-hoc compliance queries instead of relying on canned check IDs. The Powerpipe layer adds dashboards, benchmarks (CIS, NIST, PCI…), and HTML/CSV export for any of them. Useful when you need to investigate specific drift patterns rather than run a fixed audit.

**Reading the report**: open `aws_compliance.benchmark.cis_v150.*.html` and follow the failed controls — each one links back to the underlying SQL query, which you can re-run interactively in a local `steampipe query` session for deeper investigation.

</details>

<details>
<summary><b>Running this on your own AWS account</b> — what changes</summary>

When you adopt this job in a real repo, the workflow itself doesn't need to change — only the AWS side and how you treat findings:

1. **Provision an IAM role** in your account with `SecurityAudit` + `ViewOnlyAccess`, plus a trust policy that lets GitHub Actions OIDC (`token.actions.githubusercontent.com`) assume it from your repo.
2. **Set the secrets/vars** in GitHub: `AWS_IAM_ROLE_ARN` (secret), `AWS_REGION` and `AWS_IAM_ROLE_SESSION_DURATION` (variables).
3. **Decide your failure policy**: drop `-z` from the `prowler` command if you want the pipeline to fail on findings, or keep it and gate on severity (e.g. `--severity critical high`) so only the worst issues block merges.
4. **Scope the scan**: `--service iam s3` is fine for a demo, but for real use widen it (`ec2`, `rds`, `kms`, `cloudtrail`, …) or run a full `prowler aws` on a schedule and a narrower scan per PR.
5. **Triage the findings**: most checks map to a specific resource and a remediation hint. Fix the misconfiguration in your IaC (back to module 5) so the next run comes back clean — runtime scans are most useful when paired with IaC scans to catch drift.

</details>

## References
- [Prowler's State of Cloud Security Report 2025](https://prowler.com/blog/cloud-security-report-2025/)
- [Top cloud misconfigurations: A CSPM perspective](https://sysdig.com/blog/top-cloud-misconfigurations/)