# Pipeline Security Scan

> ⏱ ~15 min · 📍 Module 1 of 7
>
> **1** ▸ [2](../code_scan/) ▸ [3](../secrets_scan/) ▸ [4](../container_scan/) ▸ [5](../iac_scan/) ▸ [6](../runtime_infra_scan/) ▸ [7](../ai_review/)

This workshop module focuses on scanning the pipeline configuration itself for security vulnerabilities and misconfigurations.

## Why is Pipeline Security Important?

Many organizations overlook the pipeline as a potential attack surface. Malicious actors know that compromising your CI/CD system can grant them access to source code, privileged credentials, and even the ability to inject malicious code into your production systems without being detected by application security tools.

Pipeline security scanning analyzes your CI/CD workflows, configurations, and automation scripts to identify security risks in your deployment process.

## Common Pipeline Security Issues

- **Hardcoded Secrets in Workflows** - API keys, passwords, or tokens hardcoded in YAML files
- **Excessive Permissions** - Workflows with unnecessary write permissions
- **Untrusted Actions** - Using third-party actions without proper verification
- **Insecure Triggers** - Workflows triggered by external events without validation
- **Missing Security Controls** - No approval processes for sensitive operations

## Tools Used in This Module

| Tool | What it does | Notes |
|---|---|---|
| [**Claws**](https://github.com/Betterment/claws) | Static analysis to help write safer GitHub Actions workflows | Trusted-author allowlist via `claws-config.yml` |
| [**Zizmor**](https://github.com/woodruffw/zizmor) | Security scanner for GitHub Actions workflows | Audits for unpinned actions, expression injection and more |

## Learning Objectives

By the end of this module, you will:
- Understand pipeline security risks
- Learn to identify insecure workflow configurations
- Know how to implement pipeline security best practices
- Understand the importance of least privilege in automation

## Security Checklist

- [ ] No hardcoded secrets in workflow files
- [ ] Minimal required permissions to run the actions
- [ ] Pinned action versions
- [ ] Secure triggers and conditions
- [ ] Environment protection rules
- [ ] Audit logging enabled

## Extra Balls
- [Warden Ruse Return](./extra/WardenRuseReturns)
- [actions/checkout can leak GitHub credentials](extra/checkoutLeak/README.md)
- [Prowler: Repository Settings Scan](https://github.com/prowler-cloud/prowler) - Prowler allows you to scan Github for repository and organization misconfigurations.
  - We prepared a template for you to use in the `pipeline_scan` module.

## References
- [GitHub Action tj-actions/changed-files supply chain attack: everything you need to know](https://www.wiz.io/blog/github-action-tj-actions-changed-files-supply-chain-attack-cve-2025-30066): A supply chain attack on popular GitHub Action tj-actions/changed-files caused many repositories to leak their secrets.
- [LOTP (Living Off the Pipeline)](https://boostsecurityio.github.io/lotp/): Inventory of development tools, commonly used in CI/CD pipelines, that have RCE-By-Design features.

### GitHub Actions
- [nikitastupin/pwnhub](https://github.com/nikitastupin/pwnhub): Repository collecting resources about how GitHub Actions workflows can be hacked.
- [GitHub Actions Attack Diagram](https://github.com/jstawinski/GitHub-Actions-Attack-Diagram/blob/main/GitHub%20Actions%20Attack%20Diagram.svg): GitHub Actions Attack Diagram provides guidance for identifying GitHub Actions vulnerabilities.
- [How to Harden GitHub Actions: The Unofficial Guide](https://www.wiz.io/blog/github-actions-security-guide): A guide to hardening GitHub Actions.
- [GitHub Actions: Secure Use Reference](https://docs.github.com/en/enterprise-cloud@latest/actions/reference/secure-use-reference)
- **Keeping your GitHub Actions and workflows secure**: A series of posts about GitHub Actions security by GitHub Security Lab
  - [Preventing pwn requests](https://securitylab.github.com/resources/github-actions-preventing-pwn-requests/)
  - [Untrusted input](https://securitylab.github.com/resources/github-actions-untrusted-input/)
  - [How to trust your building blocks](https://securitylab.github.com/resources/github-actions-building-blocks/)
  - [New vulnerability patterns and mitigation strategies](https://securitylab.github.com/resources/github-actions-new-patterns-and-mitigations/)

## Solutions (spoilers — open only when stuck)

> Heads-up: each tool's snippet ships with one **planted bait line**. The very file you just pasted contains it on purpose. The CI failure is intentional — the goal of this section is to keep you from second-guessing whether you copy-pasted wrong.

<details>
<summary><b>Claws</b> — <code>UnpinnedAction</code> on <code>.github/workflows/pipeline-scan.yml:24</code></summary>

**What Claws flagged**: the snippet's `Set Up Ruby` step uses `ruby/setup-ruby@master`, a moving ref. Per `claws-config.yml`, only `actions/*` is in `trusted_authors`; every other `uses:` must be SHA-pinned.

**Fix** — pin to a tagged release SHA:

```yaml
- name: Set Up Ruby
  uses: ruby/setup-ruby@0ecad18fe538ef70f6b82773daecc6af1a7fe58a # v1.252.0
  with:
    ruby-version: '3.3'
```

Use any current SHA from a tagged release of [`ruby/setup-ruby`](https://github.com/ruby/setup-ruby/tags) — the one above is `v1.252.0` at the time of writing.

</details>

<details>
<summary><b>zizmor</b> — <code>zizmor/unpinned-uses</code> on <code>.github/workflows/pipeline-scan.yml:26</code></summary>

**What zizmor flagged**: the snippet's `Run zizmor 🌈` step uses `zizmorcore/zizmor-action@main` — same antipattern as the Claws example, just on zizmor's own action.

**Tip on reading zizmor's output**: the job log dumps the full SARIF as JSON. Search for `"ruleId"` and `"startLine"` to find the offending line without scrolling.

**Fix** — pin to a tagged release SHA:

```yaml
- name: Run zizmor 🌈
  id: zizmor
  uses: zizmorcore/zizmor-action@b1d7e1fb5de872772f31590499237e7cce841e8e # v0.5.3
  with:
    min-severity: "high"
    online-audits: "false"
```

Use any current SHA from a tagged release of [`zizmorcore/zizmor-action`](https://github.com/zizmorcore/zizmor-action/tags).

</details>
