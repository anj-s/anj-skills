---
name: doctor
description: >
  Diagnoses your development environment. Checks for missing tools, incorrect
  versions, and common configuration issues.
parameters:
  check_type:
    type: string
    description: Specific area to check (e.g., 'web', 'python', 'git').
    required: false
---

# Doctor

Ensure your development environment is healthy and ready for work.

## When to invoke

- Starting work on a new project or machine.
- When builds or tests are failing for mysterious reasons.
- After updating your OS or core development tools.

## What this skill does

1. Checks for the presence of essential tools (git, gh, node, python, etc.).
2. Verifies tool versions against project requirements (if found in `package.json`, `requirements.txt`, etc.).
3. Checks for common configuration issues (git config, environment variables).
4. Provides a "Health Report" with actionable fix suggestions.

## Instructions for Claude

When this skill is invoked:

1. **Environmental Scan**:
   - Check core CLI tools: `git`, `gh`, `curl`, `wget`.
   - Check language runtimes: `node`, `python`, `go`, `rustc` (based on project files).
   - Check package managers: `npm`, `yarn`, `pnpm`, `pip`, `cargo`.
2. **Project-Specific Checks**:
   - If `package.json` exists, check `engines` field.
   - If `.nvmrc` or `.python-version` exists, check if active version matches.
   - Check if `node_modules` or virtual environments exist and are up to date.
3. **Configuration Check**:
   - `git config user.name` and `git config user.email`.
   - `gh auth status`.
4. **Reporting**:
   - Group results by: **PASSED**, **WARNING**, **FAILED**.
   - For every WARNING or FAILED check, provide a clear instruction on how to fix it (e.g., "Run `nvm install` to match the project's node version").
5. **Verdict**: Issue a final "Ready to develop" or "Environmental issues detected" status.
