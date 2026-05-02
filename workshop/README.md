# Perfect Pipeline Introduction

> ⏱ **Estimated time:** 2–3 hours self-paced (~20 min per module).

This workshop is designed to help you understand the importance of shift-left security and how to implement comprehensive security scanning in your pipeline.

All of this without forgetting the human factor, as the final objective is not blind security but enabling your users (or yourself) to build secure software effectively.

## Workshop Goal

The idea of this workshop is to demonstrate how to build a "perfect" (secure and practical) CI/CD pipeline using open-source tools (OSS).

**The goal is inspirational, not prescriptive.** We do not want you to copy these examples, but to understand the principles and identify the modular components you can adapt to implement in your own environment.

> [!NOTE]
> **Platform-agnostic principles:* The workshop runs on GitHub Actions for convenience, but the **tools** (Semgrep, Trivy, Checkov, Prowler…) and **patterns** (shift-left, scan-then-gate, multi-layer pipeline) are universal. To take this to GitLab CI, Jenkins, CircleCI, etc., translate the orchestration glue (workflow files, secrets, triggers) and keep everything else.

## 🎓 Learning Outcomes

By completing this workshop, you will:
- Understand the importance of shift-left security
- Learn the key stages of a secure pipeline:
  - Pipeline Security
  - Static and Dynamic Code Analysis
  - Secrets Detection
  - Container Security
  - Infrastructure as Code (IaC) Security
  - Runtime Infrastructure Security
- Know relevant OSS tools for each stage
- Grasp the principles needed to start building or improving your own secure CI/CD process

Let's start with some important concepts:

### What is a Pipeline? CI/CD/CS?

A pipeline is a series of automated steps that build, test, and deploy software. It is a key part of the software development lifecycle and helps ensure that software is delivered with high quality and security.

Related to pipelines, you have probably heard about the concepts of Continuous Integration and Continuous Delivery. But to build a truly modern and resilient pipeline, we need to formally add a third component: Continuous Security.

- **Continuous Integration (CI)**: This is where developers merge code into a shared branch multiple times a day. Every merge kicks off an automated build and test, ensuring the mainline of your code is never broken for long.

- **Continuous Delivery (CD)**: This takes CI a step further. It’s an automated process that ensures any change passing the tests can be safely deployed to production with a single click, making release day a non-event.

- **Continuous Security (CS)**: This is the crucial next step in the evolution, embedding security into the process. It means automating security controls and tests throughout the pipeline, just like we do for quality, to find vulnerabilities when they are cheapest and easiest to fix.

<p align="center">
<img src="./imgs/CI_CD_CS.png" alt="CI/CD/CS" width="500">
</p>

### What is Shift-Left Security?

Shift-left security is a security practice that aims to move security checks and mitigations as early as possible in the software development lifecycle. This approach helps catch security issues early, before they reach production, and reduces the risk of vulnerabilities being exploited.

<p align="center">
<img src="./imgs/shift-left.png" alt="Shift-Left Security" width="800">
<p align="center"><em>Based on the image from https://devopedia.org/shift-left</em></p>
</p>

## How the workshop works

Each module ships as a **placeholder job** in `.github/workflows/`. You swap it for a real tool's job (provided under `workshop/<module>/<tool>/`), push, and watch the orchestrator catch a planted misconfiguration (the **bait**). Fix it, push again, green ✅. Move to the next module.

> Set up your fork in **Prerequisites** below, then jump to [**Working through a module**](#working-through-a-module) for the full step-by-step.

## Workshop Index

We suggest you follow the workshop in the following order, but feel free to jump around and explore the different modules.

1. [Pipeline Security Scan](pipeline_scan/)
2. [Code Security Scan](code_scan/)
3. [Secrets Scan](secrets_scan/)
4. [Container Security Scan](container_scan/)
5. [Infrastructure as Code Security Scan](iac_scan/)
6. [Runtime Infrastructure Scan](runtime_infra_scan/)
7. [AI Security Analysis](ai_scan/)

## Prerequisites

Before you start:

1. **Fork this repository** — you need write access to push, create branches, and configure secrets.

   [![Fork this repo](https://img.shields.io/badge/Fork-this_repo-2ea44f?logo=github&style=for-the-badge)](https://github.com/unicrons/secure-pipeline-workshop/fork)

2. **Set up your working branch.**
   On any page of **your fork**, press `.` (or change `github.com` → `github.dev` in the URL) to open a full VS Code editor in the browser. Use the branch picker (bottom-left) → create `workshop` off `main`. You're ready to edit YAMLs, commit and push from the Source Control panel. Keep `main` clean so you can compare your changes against the upstream and reset easily if something goes sideways.

   > Prefer your own editor? `git clone https://github.com/<your-user>/secure-pipeline-workshop.git && cd secure-pipeline-workshop && git checkout -b workshop`. Everything else applies the same way.

3. **(Optional) Enable GitHub Advanced Security on your fork** — some tools (Semgrep, Grype, Trivy IaC) upload SARIF for the *Code Scanning* tab. The job log already shows full findings (rule, message, file, line) regardless — GHAS just adds a richer UI on top.

4. **Per-module secrets and variables** — most modules work out of the box. The ones that don't:

   | Module | What you need | Where to get it |
   |---|---|---|
   | 2. Code Scan | `NVD_API_KEY` *(secret, optional but recommended for OWASP Dependency Check)* | [Request from NVD](https://nvd.nist.gov/developers/request-an-api-key) |
   | 6. Runtime Infra Scan | `AWS_IAM_ROLE_ARN` *(secret)*, `AWS_REGION` + `AWS_IAM_ROLE_SESSION_DURATION` *(vars)* | IAM role with `SecurityAudit` + `ViewOnlyAccess` and a GitHub OIDC trust policy |

   Configure them at `Settings → Secrets and variables → Actions` on your fork.

## Working through a module

For each module:

1. **Read** the module's `README.md` for context (why, common issues, tools available).
2. **Pick a tool** and open `workshop/<module>/<tool>/workflow.yml`. The header comments list any extra prerequisites for that tool.
3. **Replace** the entire `jobs:` section of `.github/workflows/<module>-scan.yml` with the `jobs:` section from the tool's `workflow.yml`. Keep the file's `name:`, `on:`, `inputs:`, `secrets:`, and `outputs:` blocks intact.
4. **Commit and push** to your `workshop` branch.
5. **Open a Pull Request** from `workshop` → your fork's `main`. GitHub shows a *"Compare & pull request"* banner right after the push — one click. The orchestrator runs as PR checks, so you can watch the whole pipeline directly from the PR's *Checks* tab without leaving the page. Every additional push to `workshop` re-runs the checks on the same PR (no need to reopen anything).
6. **Read the failure**: each module ships with a planted **bait** (a misconfiguration or vulnerable line) the scanner is meant to catch. The job log points at the file and line. If you get stuck, the module's `Solutions` section is your safety net.
7. **Fix the bait** and push again until the job goes green ✅.
8. **(Optional)** Try a second tool in the same module — it usually flags the same bait, so the existing fix clears it too.
9. **Move on** to the next module.

> ℹ️ **The orchestrator runs every module's job on every push.** Modules whose placeholder you haven't replaced stay green by design (the placeholder just echoes a message). Focus on the job for the module you're working on.

> ℹ️ **Module 6 exception**: the runtime infra scan runs against a *live AWS account*, so there's no planted bait to fix. It's expected to pass green even when Prowler reports findings — see its `Running this module` section.

## Out of Scope (What this workshop is NOT)

- Deep dives into specific development workflows (e.g., Gitflow vs. Trunk-based)
- Focus on a specific application technology stack (language/framework agnostic where possible)
- A definitive statement on the "best" tools (alternatives will be mentioned for key steps)
