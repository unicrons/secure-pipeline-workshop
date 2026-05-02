# `infra/` — sample Terraform scanned by the workshop

This directory contains the Terraform resources that **Module 5: IaC Security
Scan** runs Checkov and Trivy IaC against. It defines an ECS Fargate sample
deployment with **one intentional misconfiguration** (the bait) for the
scanners to catch.

> [!NOTE]
> These files are **never applied locally** — the workshop is zero-install.
> All scans run in GitHub Actions via `pipeline-orchestrator.yml`.

- 📘 [Module 5 — IaC Security Scan](../workshop/iac_scan/) — context, tools, instructions
- 🐛 [The intentional bait + fix](../workshop/iac_scan/#solutions) — spoilers, open only when stuck
- 🛰 [Module 6 — Runtime Infrastructure Scan](../workshop/runtime_infra_scan/) — what would scan this in production
