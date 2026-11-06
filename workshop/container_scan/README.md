# Container Security Scan

> ⏱ ~15 min · 📍 Module 4 of 7
>
> [1](../pipeline_scan/) ▸ [2](../code_scan/) ▸ [3](../secrets_scan/) ▸ **4** ▸ [5](../iac_scan/) ▸ [6](../runtime_infra_scan/) ▸ [7](../ai_review/)

This workshop module covers container security scanning to identify vulnerabilities in container images and configurations.

## Why is Container Security Important?
Containers are now one of the most common ways to deploy applications. They are also attractive targets for attackers who can use them to access underlying infrastructure, steal secrets (including cloud credentials), or execute arbitrary code.

Container security scanning analyzes images and container configurations to identify security vulnerabilities, misconfigurations, and compliance issues before releasing them.

## Common Container Security Issues

### Image Vulnerabilities:
- **Image Vulnerabilities** - Outdated or vulnerable dependencies, both in the base image and in the application dependencies.
- **Supply Chain** - Untrusted base images. Trojanized or typo-squatted images pulled from public registries.
- **Secrets in Images** - Hardcoded credentials or keys.

### Configuration Issues:
- **Root User** - Running containers as root
- **Excessive Privileges** - Unnecessary capabilities can allow container escape.
- **Exposed Ports** - Unintended network exposure
- **Missing Security Controls** - No health checks or resource limits
- **Weak Network Segmentation** - Overly permissive ingress rules allow lateral movement
- **Dangerous Volumes** - Mounting host volumes can expose sensitive data or allow privilege escalation.

## Tools Used in This Module

| Tool | What it does | Notes |
|---|---|---|
| [**Trivy**](https://github.com/aquasecurity/trivy) | Vulnerability, misconfiguration and secret scanner for containers | Also scans filesystems, IaC and repos; this module focuses on containers |
| [**Grype**](https://github.com/anchore/grype) | Fast vulnerability scanner for container images and filesystems | By Anchore; uses multiple vuln DBs and generates SBOM automatically |

## Learning Objectives

By the end of this module, you will:
- Understand container security risks
- Learn to scan images for vulnerabilities
- Understand supply chain security for containers
- Identify Dockerfile security best practices

> [!TIP]
> **A clean scan can take more than one fix.** Bumping the base image
> clears OS-package and language-runtime CVEs, but transitive dependencies
> bundled inside the new image (e.g., libraries shipped with the global
> package manager) may still surface as HIGH findings. Expect to fix in
> layers — re-run the scanner between each change to see what's left.

## Security Checklist

- [ ] **Use minimal, trusted base images** and rebuild them regularly.
- [ ] **Patch all High/Critical CVEs** before shipping; fail the build if any remain.
  - Note: You can also ignore them if you verified the vulnerability is not exploitable.
- [ ] **Run containers as a non-root user** with only the capabilities they truly need.
- [ ] **Remove build tools & secrets** via multi-stage builds to shrink the attack surface.
- [ ] **Sign images and verify signatures** at pull/admission time to ensure provenance.
- [ ] **Enable runtime protection** ([seccomp](https://docs.docker.com/engine/security/seccomp/)/[AppArmor](https://docs.docker.com/engine/security/apparmor/) profiles, resource limits, live detection).
- [ ] **Implement health and readiness checks**



## References
- [NetRise Releases Supply Chain Visibility & Risk Study, Edition 2: Containers, Revealing Signicant Visibility and Risk Challenges within Common Containers](https://www.netrise.io/en/company/announcements/netrise-releases-supply-chain-visibility-risk-study-revealing-signicant-visibility-and-risk-challenges-within-common-containers): Research finds containers have over 600 vulnerabilities a piece on average.
- [Top 10 Container Security Issues](https://www.sentinelone.com/cybersecurity-101/cloud-security/container-security-issues/)
- [Docker Engine security](https://docs.docker.com/engine/security/)

### Other Tools
- [slimtoolkit/slim](https://github.com/slimtoolkit/slim): Tool to reduce the size of container images (making them more secure).

## Solutions (spoilers — open only when stuck)

> The container bait is the **base image** in `code/Dockerfile` — it ships with an EOL alpine that has unpatched HIGHs. The CI failure is intentional.

<details>
<summary><b>Trivy</b> — alpine OS-layer HIGHs (<code>musl</code>, etc.)</summary>

**What Trivy flagged**: an `alpine 3.19.4` base ships `musl` / `musl-utils` HIGHs (e.g. `CVE-2025-26519`, `CVE-2026-40200`) and EOL warnings.

**Reading the output**: Trivy prints a clean table (Library / Vulnerability / Severity / Status / Installed Version / Fixed Version / Title), grouped by **target**. Each target is a different layer of the image, and each layer needs its own fix:

| Target in the output | What it is | Fix |
|---|---|---|
| `<image> (alpine 3.19.4)` | OS packages of the base image | Bump `FROM` to a current LTS tag |
| `Node.js` — `brace-expansion`, `undici`, `tar`, `pacote`… | The global `npm` bundled in the image | Bump the `npm@…` pin in the Dockerfile |
| `Node.js` — `axios`, `follow-redirects`, `form-data` | The app's own dependencies | That's module 2's bait — if you fixed it there, this layer is already gone |

> ⚠️ **Don't just bump alpine minor**: `node:20-alpine3.19` → `node:20-alpine3.21` actually *increases* the finding count (alpine 3.21 still ships an unpatched openssl). Jump to a current node-major instead.

> ⚠️ **Odd Node majors are not LTS**: `node:25-alpine` sits on a newer alpine, but at the time of writing it scans *worse* than the bait (openssl, zlib and musl HIGHs). Pick an even, LTS major.

> ⚠️ **"Fixed Version" is per-CVE, not per-package**: bumping to the version Trivy lists in that column only closes the CVE you happened to look at. Pick the latest stable image tag.

**Fix** — bump the base image *and* the npm pin:

```diff
-FROM node:20-alpine3.19
+FROM node:26-alpine

-RUN npm install -g npm@11.13.0 && npm cache clean --force
+RUN npm install -g npm@12.2.2 && npm cache clean --force
```

If you haven't done module 2 yet, also bump `axios` and regenerate the lockfile as described in its [Solutions](../code_scan/README.md#solutions-spoilers--open-only-when-stuck) — otherwise the `axios` layer keeps the job red.

Same for module 3: Trivy also runs its secret scanner on the image, so the hardcoded AWS keys in `src/simple-app.js` show up as `aws-access-key-id` / `aws-secret-access-key` findings until you move them to `process.env.*`.

> Tip: scan locally before pushing: `docker build -t app code && trivy image --severity HIGH,CRITICAL --ignore-unfixed app`. At the time of writing `node:26-alpine` + `npm@12.2.2` + `axios@1.21.0` scanned clean on both Trivy and Grype; check the latest tags before committing.

</details>

<details>
<summary><b>Grype</b> — same root cause, terser output</summary>

**What Grype reports**: the `Summarize findings` step parses the SARIF and prints each CVE as `ruleId | message | path:line` to the job log — plus a helpful warning: `188 packages from EOL distro "alpine 3.19.4"`. The full SARIF is also uploaded to the GitHub *Code Scanning* tab if your fork has GHAS enabled.

**Same root cause as Trivy**: EOL alpine base.

**Fix** — identical to the Trivy fix above.

</details>