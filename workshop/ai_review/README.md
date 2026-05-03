# AI Security Review

> ⏱ ~15 min · 📍 Module 7 of 7
>
> [1](../pipeline_scan/) ▸ [2](../code_scan/) ▸ [3](../secrets_scan/) ▸ [4](../container_scan/) ▸ [5](../iac_scan/) ▸ [6](../runtime_infra_scan/) ▸ **7**

This workshop module adds an AI step to the pipeline that reviews application code and posts a structured security report on every pull request. The deterministic scanners from modules 1-6 catch what their rules and signatures know to look for; this module covers the gap.

## Why is AI Code Review Important?

SAST, SCA, secrets scanners and IaC scanners are pattern matchers. They are excellent at what they were built for: rules, signatures, AST queries, known-vulnerable versions. But there are entire classes of issues that fall outside their reach.

- **Fix-incomplete traps** — closing the obvious sink while leaving an adjacent issue open (e.g. parameterising a SQL query on one call site but still concatenating on two others). The pattern rule that triggered on the first sink is now silent; the bypass still works.
- **Cross-function taint flows** — user input that reaches a sink across three function calls and a closure. AST-based rules typically operate on a single function or file at a time and lose the trail.
- **Intent and design issues** — an endpoint that performs a sensitive action without authentication, an error path that silently swallows misconfiguration. No regex flags these; a reader who understands the code does.
- **Best-practice drift** — deprecated security headers linger long after browsers stopped honouring them; an IAM policy uses a wildcard action; a cookie misses `Secure` or `HttpOnly`. Each is contextual; rule packs cover some but not all.

A large language model with the source file in its context window reads the code the way a human reviewer would. It complements the deterministic stack from modules 1-6, but its output can hallucinate or restate what scanners already found — treat it as input to triage rather than authority.

> [!TIP]
> Treat AI findings as input to triage, not as merge-blockers. Pair them with a human review and the deterministic SARIF from prior modules. Two signals beat one.

## Common Issues AI Catches That Scanners Don't

### Fix-Incomplete Traps
A developer addresses one signature-flagged issue but leaves an adjacent vulnerability open. The scanner is now green; the application is still broken. AI sees the broader function and notices the gap.

### Cross-Function Taint Flows
User input enters at one function, is passed through a helper, mutated by a third, and reaches a sink. Rules that operate per-function lose the trail; an LLM with the file in context follows it.

### Authentication & Authorization Gaps
"This endpoint reads files. There is no auth check before the read." This is design-level, not pattern-level — exactly where AI complements scanners.

### Deprecated or Missing Best Practices
`X-XSS-Protection` headers, missing CSP, weak cookie attributes, deprecated crypto APIs. The list shifts year to year; an up-to-date model knows what 2026 best practice looks like.

### Silent Error Handling
`try { ... } catch { defaults }` patterns that mask configuration failures, deserialization errors that fall through to permissive defaults. Not a CVE; still a real bug.

## Tools Used in This Module

| Tool | Pick when | Notes |
|---|---|---|
| [**Google Gemini**](https://ai.google.dev/) | You want a free tier with no credit card and a fast model. | Default for this module. Gemini 2.5 Flash, 250 requests/day per user. |

Other AI security review options exist (Claude, OpenAI GPT, GitHub Copilot Autofix, Snyk Code AI). They are listed under [Other Tools](#other-tools) below.

## Setup

This is the only module in the workshop that talks to a third-party API. You need one secret on your fork and nothing installed locally.

### 1. Get a Gemini API key

> 🔗 **[Open Google AI Studio → Create API key](https://aistudio.google.com/apikey)**

1. Sign in with any Google account.
2. Click **"Create API key"** → *"Create API key in new project"*.
3. Copy the key. You can return to the same page anytime to view or regenerate it.

The free tier provides **250 requests/day on Gemini 2.5 Flash** — well more than this workshop needs. If you hit the daily quota (`429 RESOURCE_EXHAUSTED` in the job log), switch the snippet's `model` to `gemini-2.5-flash-lite` (1000/day). No billing setup, no Google Cloud project to configure.

### 2. Save it as a repository secret

In your fork on GitHub:

1. **Settings → Secrets and variables → Actions**.
2. Click **"New repository secret"**.
3. Name: `GEMINI_API_KEY` · Value: paste the key from step 1.
4. Click **"Add secret"**.

> 🔗 Direct path: `https://github.com/<your-user>/secure-pipeline-workshop/settings/secrets/actions/new`

### 3. Privacy disclaimer

This module sends the contents of `code/src/simple-app.js` to Google's Gemini API.

- **On the free tier, Google may use your inputs and outputs to improve their models.** ([Gemini API terms](https://ai.google.dev/gemini-api/terms))
- ✅ **Fine for this workshop.** The code is a deliberate, public sample. The `AKIA…` literals in `simple-app.js` are didactic — not real, not validated against AWS.
- ❌ **Not for real proprietary code.** For production use, switch to a paid tier (which excludes your data from training) or self-host an open-weight model.

## Learning Objectives

By the end of this module, you will:
- Understand where deterministic scanners fall short and where AI complements them
- Configure an AI review step inside a GitHub Actions pipeline using a structured-output prompt
- Read and triage findings produced by a model, distinguishing them from SAST/secrets output
- Recognise the operational concerns of running AI in a pipeline: cost, rate limits, privacy, non-determinism, prompt injection

## Security Checklist

- [ ] API key stored as a repository secret, never committed
- [ ] Privacy implications understood and accepted (data sent to third party on free tier)
- [ ] Token budget per run capped (`max-completion-tokens`)
- [ ] Rate-limit budget per day understood (free tier: 250 req/day on Flash)
- [ ] AI findings reviewed by a human; not auto-merged or auto-closed
- [ ] Untrusted input wrapped in delimiters in the prompt (defence against prompt injection)
- [ ] AI step is a complement to SAST/secrets scanners, not a replacement
- [ ] Output format is structured (JSON) and validated before posting

## References

- [Google AI Studio — get an API key](https://aistudio.google.com/apikey)
- [Gemini API rate limits and pricing](https://ai.google.dev/gemini-api/docs/rate-limits)
- [OWASP Top 10 for LLM Applications](https://genai.owasp.org/llm-top-10/) — prompt injection, output handling, and the rest of the LLM-specific risk catalogue
- [Finding vulnerabilities in modern web apps using Claude Code and OpenAI Codex](https://semgrep.dev/blog/2025/finding-vulnerabilities-in-modern-web-apps-using-claude-code-and-openai-codex)

### Other Tools

**Open-source / self-hosted** — when code must not leave your infrastructure:
- [**PR-Agent**](https://github.com/qodo-ai/pr-agent) (Qodo, AGPL-3.0) — full-featured OSS AI code-review action; pluggable LLM backend with your own keys.
- [**Ollama**](https://ollama.com/) running open-weight code models on a self-hosted runner: [Qwen2.5-Coder](https://qwenlm.github.io/blog/qwen2.5-coder-family/), [Llama 3.x](https://www.llama.com/), [DeepSeek-Coder](https://github.com/deepseek-ai/DeepSeek-Coder), [Codestral](https://mistral.ai/news/codestral-25-01). Same `responseSchema` pattern as this module's snippet, no third-party API call.

**Open-weight models, hosted** — same models, served via an API (free tiers, no self-hosting):
- [**Groq**](https://groq.com/) — Llama / Qwen / Mixtral on custom hardware (LPUs), OpenAI-compatible API, generous free tier without a credit card.
- [**Together AI**](https://www.together.ai/), [**Fireworks AI**](https://fireworks.ai/) — broader catalogs of open-weight models behind a single API.

**GitHub-native (free):**
- [**Copilot Autofix**](https://docs.github.com/en/code-security/code-scanning/managing-code-scanning-alerts/about-autofix-for-code-scanning) — free for public repos with GHAS, surfaces fix proposals on CodeQL alerts directly in the *Code Scanning* tab. Complementary to this module.

**Commercial APIs (closed-weight models):**
- [**Anthropic Claude**](https://docs.claude.com/en/api/overview) via [`claude-code-action`](https://github.com/anthropics/claude-code-action) — agentic review with tool use. For *opt-in* invocation instead of a pipeline step, `claude-code-action` also gates on `issue_comment` slash commands (e.g. `/claude review`) — out of scope for this module, but a worked example of the chat-driven pattern.

## Solutions (spoilers — open only when stuck)

> No bait specific to this module. The PR comment posted by the AI step *is* the output you're looking for — read it on your PR. Each finding includes its own location, evidence, and fix.
>
> Output is non-deterministic: wording, finding count, ordering and even reported line numbers vary between runs. Treat severities and locations as approximate.
>
> Severity legend: 🔴 Critical · 🟠 High · 🟡 Medium · 🔵 Low · ⚪ Info.
