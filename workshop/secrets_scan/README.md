# Secrets Scan

> ⏱ ~15 min · 📍 Module 3 of 7
>
> [1](../pipeline_scan/) ▸ [2](../code_scan/) ▸ **3** ▸ [4](../container_scan/) ▸ [5](../iac_scan/) ▸ [6](../runtime_infra_scan/) ▸ [7](../ai_review/)

This workshop module focuses on identifying and preventing the exposure of sensitive credentials, API keys, and other secrets in source code, configuration files, and git history.

## Why is Secrets Scan Important?
This is an old problem, but it is still a common one ([especially with the AI surge](https://www.wiz.io/blog/leaking-ai-secrets-in-public-code)). Secrets are the keys to your kingdom. If a password or token is accidentally committed to code, it's immediately at risk, potentially leading to:

- **Data Breaches** - Exposed credentials can lead to unauthorized access
- **Access to our Systems** - Compromised secrets enable lateral movement
- **Supply Chain Attacks** - Compromised release artifacts

All of this can lead to:

- **Compliance Issues** - Regulatory requirements for data protection
- **Financial Loss** - Unauthorized usage of cloud services
- **Reputation Damage** - Public exposure of security incidents

Secrets scan involves scanning code repositories, commit history, and configuration files to identify exposed credentials such as API keys, passwords, tokens, certificates, and other sensitive information that should not be stored in version control.

> [!TIP]
> Ideally, we should implement this before pushing the code to the repository, using [pre-commit](https://github.com/pre-commit/pre-commit) or similar tools. But accidents happen, so it's important to have a process to detect them in the pipeline as a safety net.

### Common Types of Secrets

GitGuardian detected **28.65M new hardcoded secrets** in public GitHub during 2025 (+34% YoY), with **AI-related credentials behind 8 of the 10 fastest-growing categories**. [^1]

#### **AI / LLM Service Keys**
- Core providers (OpenAI, Anthropic, Google AI, Mistral, xAI, DeepSeek), LLM infrastructure (RAG, orchestration, vector stores) and AI gateways (OpenRouter, Groq)
- +81% YoY in 2025 — LLM infrastructure leaks growing **5× faster** than core providers
#### **MCP Configuration Files**
- Credentials embedded in Model Context Protocol server configs (API keys passed as CLI args or `env` blocks committed to version control)
- 24,008 unique secrets exposed in public MCP configs in 2025 — top types: Google API, PostgreSQL, Firecrawl, Perplexity, Brave Search
#### **Generic Credentials**
- Hardcoded passwords, database connection strings, custom tokens, plaintext encryption keys
- The largest single bucket year after year, often slipping past specific-pattern detectors
#### **Database Service Credentials**
- MongoDB connection strings, MySQL/PostgreSQL credentials
- Frequently bundled inside `.env` files or MCP `DATABASE_URI` fields
#### **Cloud Provider Keys**
- AWS IAM access keys, Google Cloud keys, Azure SAS tokens
- High blast radius — direct path to lateral movement in cloud accounts
#### **Third-Party API Keys**
- Stripe, Twilio, SendGrid, payment processors, monitoring SaaS, etc.
- Modern apps integrate dozens of these — each one a potential leak source
#### **Messaging/Bot Tokens**
- Telegram Bot tokens, Slack/Discord webhooks
- Used by attackers for impersonation, data exfiltration and social-engineering pivots
#### **Private Cryptographic Material**
- RSA/SSH private keys, JWT signing keys, TLS certificates
- Consistently in the top-10 leak types
#### **OAuth/Personal Access Tokens**
- GitHub PATs, fine-grained PATs, GitLab tokens
- Frequently classified as critical — the Shai-Hulud 2 supply-chain attack alone harvested 581 GitHub PATs + 386 OAuth tokens from compromised dev machines in 2025

> ⚠️ **Detection ≠ remediation.** **64% of secrets confirmed valid in 2022 are still valid in 2026.** [^1] Pair detection with a clear rotation/revocation playbook.

### Other types of secrets or sensitive data
There are other types of secrets or sensitive data that may not be covered by the tools we will use in this workshop, but that are still important to keep in mind:

#### **Webhooks**
- Webhooks are used to trigger actions in other systems, and can be used to trigger malicious actions.
  - Like Slack webhooks, that can be used to impersonate a user and send messages to a channel.
#### **AWS Account IDs**
- AWS account IDs (or other cloud provider identifiers) can be used to enumerate resources and help attackers to map the attack surface.
  - There's a lot of discussion about if this should be considered a secret or not. [According to AWS they are not](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-identifiers.html), but we think this article from Daniel Grzelak is a good explanation of why they are: [The Final Answer: AWS Account IDs Are Secrets](https://www.plerion.com/blog/the-final-answer-aws-account-ids-are-secrets)
#### **Internal Documents or PII**
- PDFs, log files, customer data dumps, identity scans and even bank statements that slip into repos during troubleshooting or demo work.

## Tools Used in This Module

| Tool | What it does | Notes |
|---|---|---|
| [**TruffleHog**](https://github.com/trufflesecurity/trufflehog) | Git history secrets scanner | Verifies findings against live providers when possible |
| [**Gitleaks**](https://github.com/gitleaks/gitleaks) | Git history and filesystem secrets scanner | Rule-based; tunable via `.gitleaks.toml` |

## Learning Objectives

By the end of this module, you will:
- Understand different types of secrets and their risks
- Learn to use automated secrets detection tools
- Know how to scan git history for leaked credentials
- Learn to prevent future secret exposures

## Security Checklist

- [ ] Use environment variables for secrets
- [ ] Implement proper .gitignore patterns
- [ ] No secrets in source code
- [ ] Git history cleaned of secrets
- [ ] Environment variables properly configured
- [ ] Secrets management solution implemented
- [ ] Pre-commit hooks for secrets detection
- [ ] Rotate compromised credentials immediately
- [ ] Regular secrets auditing process

## References
- [GitGuardian — The State of Secrets Sprawl 2026](https://www.gitguardian.com/state-of-secrets-sprawl-report): the 5th-edition report covering AI-fueled leaks, MCP configuration sprawl and credential persistence trends.
- [How did OpenAI detect that my API key was pushed to GitHub?](https://www.reddit.com/r/OpenAI/comments/zotyq4/how_did_openai_detect_that_my_api_key_was_pushed/): Reddit user surprised because OpenAI contacted him seconds after pushing an API key to GitHub.

[^1]: [GitGuardian — The State of Secrets Sprawl 2026](https://www.gitguardian.com/state-of-secrets-sprawl-report)

## Solutions (spoilers — open only when stuck)

> The bait is two hardcoded AWS credentials at `code/src/simple-app.js:4-5`. They're a didactic AKIA — not real and not validated against AWS — but secret scanners detect them by format. The CI failures are intentional.

<details>
<summary><b>TruffleHog</b> — <code>Detector Type: AWS</code> at <code>code/src/simple-app.js:4</code></summary>

**What TruffleHog flagged**: 1 unverified result on the `AKIA…` access-key literal. Look in the **`Summarize findings`** step:

```
❌ Found 1 TruffleHog finding(s):
  - AWS | verified=false
      code/src/simple-app.js:4
```

**Why the snippet uses `--results=verified,unknown,unverified`**: the workshop's AKIA is not a real AWS key, so TruffleHog can't validate it against AWS. Under the default `verified`-only filter the build would silently pass — the extra flags are what make the bait fire.

**Why we run with `--json`**: the snippet pipes JSON output into a follow-up `Summarize findings` step (same shape as the other workshop modules). The default `verified=false` field tells you the secret matched a pattern but couldn't be validated against the live provider.

**Fix** — move the hardcoded credentials to environment variables:

```diff
-const AWS_ACCESS_KEY_ID = 'AKIA…REDACTED'
-const AWS_SECRET_ACCESS_KEY = '[redacted-40-char-secret]'
+const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID;
+const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY;
```

</details>

<details>
<summary><b>Gitleaks</b> — <code>aws-access-token</code> + <code>generic-api-key</code> at <code>code/src/simple-app.js:4-5</code></summary>

**What Gitleaks flagged**: 2 leaks — the access-key (rule `aws-access-token`) and the secret-key (rule `generic-api-key`, high-entropy match). The output has rich detail (Finding / Secret / RuleID / Entropy / File / Line / Fingerprint), but the `wget`-based install pollutes the log with a progress bar — scroll past it to find `Finding:`.

**Snippet note**: the snippet uses `--no-git` so only the current filesystem is scanned, not git history. Once your latest commit is clean, Gitleaks goes green even if older commits on the branch still contain the literals.

**Fix** — same as TruffleHog (move both to `process.env.*`). One edit clears both rules.

</details>

> ⚠️ **If you write notes inside this repo** (e.g. a `docs/` writeup that quotes the bait literals), Gitleaks will trip on your notes too. Either redact (`AKIA…REDACTED`, `[redacted-40-char-secret]`) or add a `.gitleaksignore` covering your notes path.