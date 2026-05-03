# Secure Pipeline Workshop

Welcome to the "Secure Pipeline" workshop! This hands-on workshop teaches you how to build a comprehensive security-focused CI/CD pipeline with multiple layers of security scanning and best practices.

> ⏱ **Estimated time:** 2–3 hours self-paced (~20 min per module).

> [!NOTE]
> **Platform-agnostic principles:** This workshop runs on GitHub Actions for hands-on convenience, but the **tools** (Semgrep, Trivy, Checkov, Prowler…) and **patterns** (shift-left, scan-then-gate, multi-layer pipeline) are universal. To run this on GitLab CI, Jenkins, CircleCI, etc., you'd translate the orchestration glue (workflow files, secrets, triggers) but keep everything else.


## 📁 Repository Structure

```
├── .github/workflows/               # GitHub Actions workflows
├── code/                            # Sample vulnerable application
├── infra/                           # Terraform infrastructure
└── workshop/                        # Workshop modules and documentation
```

## 📚 Workshop Modules

> 🐦‍🔥 New here? Start with the [workshop introduction](workshop/) for context on shift-left, CI/CD/CS, prerequisites, and how the workshop works.

### 1. 🛡️ [Pipeline Security Scan](workshop/pipeline_scan/)
Detect insecure GitHub Actions patterns: unpinned actions, excessive permissions, untrusted authors.

### 2. 🔬 [Code Security Scan](workshop/code_scan/)
Find vulnerabilities in your application code (SAST) and in its dependencies (SCA).

### 3. 🔐 [Secrets Scan](workshop/secrets_scan/)
Detect and prevent exposure of credentials and sensitive information.

### 4. 🐳 [Container Security Scan](workshop/container_scan/)
Scan Docker images for vulnerabilities and misconfigurations.

### 5. 🏗️ [Infrastructure as Code (IaC) Security Scan](workshop/iac_scan/)
Analyze Terraform and other IaC definitions for security issues before they are deployed.

### 6. ☁️ [Runtime Infrastructure Scan (live cloud)](workshop/runtime_infra_scan/)
Scan a live AWS account for misconfigurations and drift that static IaC scans can't catch.

### 7. 🤖 [AI Security Review](workshop/ai_review/) *(optional)*
Leverage AI to perform comprehensive, context-aware security reviews of pull requests.

---

## 🤝 Contributing

This workshop is designed to be continuously improved. Feel free to:
- Report issues or suggest improvements
- Add new security scenarios
- Contribute additional tool integrations
- Share your workshop experience

## 📄 License

This workshop is provided under the MIT License for educational purposes.

---

**Ready to build the perfect secure pipeline? Start [here](workshop/)! 🚀**
