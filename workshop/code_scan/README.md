# Code Security Scan (SAST/SCA)

> ⏱ ~25 min (SAST + SCA) · 📍 Module 2 of 7
>
> [1](../pipeline_scan/) ▸ **2** ▸ [3](../secrets_scan/) ▸ [4](../container_scan/) ▸ [5](../iac_scan/) ▸ [6](../runtime_infra_scan/) ▸ [7](../ai_review/)

> [!IMPORTANT]
> **This module is the only one with two placeholders.** `.github/workflows/code-scan.yml`
> ships with both a `sast-scan` and an `sca-scan` placeholder, because Code Scan covers
> two complementary techniques. You can:
>
> - **Pick one** (replace the entire `jobs:` block with a single tool's job — quickest), or
> - **Pick one of each** (paste both a SAST tool's job and an SCA tool's job into the same
>   `jobs:` block, making sure each job has a unique key — full coverage).

This workshop module covers Static Application Security Testing (SAST) and Software Composition Analysis (SCA) to identify security vulnerabilities in application code and dependencies.

## Why is Code Security Important?

Vulnerabilities in your code or your dependencies are the path attackers take to gain unauthorized access, steal data, or disrupt your systems. Two complementary techniques cover the bulk of the surface:

- **SAST (Static Application Security Testing)** — analyzes source code without executing it, looking at patterns, data flow and control flow to surface issues like injection, XSS or unsafe APIs.
- **SCA (Software Composition Analysis)** — analyzes your open-source dependencies to flag known CVEs, outdated packages and license issues.

## Common Code Security Issues

### SAST Findings:
- **SQL Injection** - Unsafe database queries
- **Cross-Site Scripting (XSS)** - Unvalidated user input
- **Command Injection** - Direct execution of system commands with user data
- **Path Traversal** - Unsafe file access with user-controlled paths
- **Authentication Flaws** - Weak authentication mechanisms
- **Authorization Issues** - Missing access controls
- **Hardcoded Secrets** - Credentials in source code
- **Input Validation** - Missing or improper validation

### SCA Findings:
- **Known Vulnerabilities** - CVEs in dependencies
- **Outdated Packages** - Dependencies with security updates
- **License Issues** - Non-compliant licenses
- **Supply Chain Risks** - Malicious packages

## Tools Used in This Module

| Tool | Type | What it does | Notes |
|---|---|---|---|
| [**CodeQL**](https://github.com/github/codeql) | SAST | GitHub's semantic code analysis engine for deep security analysis | [Action](https://github.com/github/codeql-action) · [Docs](https://codeql.github.com/docs/) |
| [**Semgrep**](https://github.com/semgrep/semgrep) | SAST | Fast pattern-based scanner with extensive rule sets | [Docs](https://semgrep.dev/docs/) · [Community rules](https://semgrep.dev/explore) |
| [**osv-scanner**](https://github.com/google/osv-scanner) | SCA | Lockfile-based vulnerability scanner backed by [OSV.dev](https://osv.dev/) | [Action](https://github.com/google/osv-scanner-action) · [Docs](https://google.github.io/osv-scanner/) |
| [**OWASP Dependency Check**](https://github.com/dependency-check/DependencyCheck) | SCA | OWASP SCA tool for known vulnerabilities in dependencies | Requires `NVD_API_KEY` ([request one](https://nvd.nist.gov/developers/request-an-api-key)) — without it, the scan may return 0 findings |

> **Note**: Different ecosystems have specialized SAST tools (e.g., ESLint with security plugins for JavaScript, Bandit for Python, Brakeman for Ruby on Rails) that can provide more targeted analysis alongside general-purpose scanners.

## Learning Objectives

By the end of this module, you will:
- Understand the difference between SAST and SCA
- Learn to configure and run security scanners
- Understand common vulnerability patterns
- Learn to integrate security scanning into CI/CD

## Security Checklist

- [ ] SAST integrated into CI/CD pipeline
- [ ] SCA scanning for all dependencies
- [ ] Regular dependency updates
- [ ] Security hotspots addressed
- [ ] False positive management
- [ ] Security metrics tracking

## References

- [OWASP Top Ten](https://owasp.org/www-project-top-ten/) — the canonical list of the most critical web application security risks; most SAST rule packs map back to it.
- [OWASP Application Security Verification Standard (ASVS)](https://owasp.org/www-project-application-security-verification-standard/) — concrete requirements you can audit your code against.
- [GitHub: About code scanning](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning) — how SARIF uploads surface in the *Security → Code scanning* tab.
- [OSV.dev](https://osv.dev/) — the vulnerability database that powers `osv-scanner`; useful for manually checking a single package.
- [Snyk: SAST vs DAST vs SCA](https://snyk.io/learn/application-security/sast-vs-dast-vs-sca/) — quick comparison of the three flavours of code/dependency analysis.

## Solutions (spoilers — open only when stuck)

> The bait for this module lives in two places: a vulnerable code pattern in `code/src/simple-app.js` (SAST) and a known-vulnerable dependency in `code/package.json` (SCA). The CI failures are intentional.

<details>
<summary><b>CodeQL (SAST)</b> — <code>js/command-line-injection</code> at <code>code/src/simple-app.js:42</code></summary>

**What CodeQL flagged**: `exec(\`cat "${filePath}"\`, …)` flows the user-controlled `filePath` from the request body straight into a shell command. The TODO comment on the line above (`// TODO: Tech debt - should use fs.readFile instead of shell command for security`) hints at the intended fix.

**Reading the output**: the snippet's `Summarize findings` step prints `ruleId | message | path:line` — exactly the format you need.

**Fix** — replace the `exec(...)` with `fs.readFile(...)` confined to a safe base directory (the `path.resolve` + `startsWith` guard also clears any follow-up path-traversal rule):

```js
if (filePath) {
  const fs = require('fs');
  const path = require('path');

  const safeBase = path.resolve(__dirname, 'public');
  const resolved = path.resolve(safeBase, filePath);
  if (!resolved.startsWith(safeBase + path.sep)) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Invalid path' }));
    return;
  }

  fs.readFile('./config.json', 'utf8', (configErr, configData) => {
    const config = configErr ? { debug: false } : JSON.parse(configData);

    fs.readFile(resolved, 'utf8', (error, stdout) => {
      if (error) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
        return;
      }
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ config: config, content: stdout }));
    });
  });
}
```

> Heads-up on CI wall-clock: each CodeQL run takes 4-5 minutes (init + database create + analyze). It's not stuck.

</details>

<details>
<summary><b>Semgrep (SAST)</b> — <code>javascript.lang.security.audit.detect-child-process</code> at <code>code/src/simple-app.js:42</code></summary>

**Reading the output**: the snippet's `Summarize findings` step parses the SARIF and prints `ruleId | message | path:line` directly to the job log — no GHAS required. If your fork has GHAS enabled, the SARIF is also uploaded to the *Code Scanning* tab for a richer UI.

**Same root cause as CodeQL**: the `exec(\`cat "${filePath}"\`, …)` line.

**Fix** — identical to the CodeQL fix above.

</details>

<details>
<summary><b>osv-scanner (SCA)</b> — multiple CVEs on <code>axios@1.6.0</code> in <code>code/package.json</code></summary>

**What osv-scanner flagged**: `axios@1.6.0` has multiple known CVEs (SSRF, DoS, credential leakage, etc.). The snippet's `Summarize findings` step prints them as `CVE-… | Package … is vulnerable to …`.

**Fix** — bump `axios` to a recent patched version. Don't pick the lowest version that closes a single CVE; pick the latest stable patch level (CVEs in the same package keep coming):

```diff
   "dependencies": {
-    "axios": "1.6.0"
+    "axios": "1.15.2"
   }
```

Then regenerate the lockfile so it stays in sync with `package.json`:

```bash
cd code
rm -f package-lock.json
npm install --package-lock-only
cd ..
git add code/package.json code/package-lock.json
```

> Tip: `npm view axios versions` lists the available versions. At the time of writing `1.15.2` was clean; check the latest before committing.

</details>
