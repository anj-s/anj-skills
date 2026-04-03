---
name: open-issues
description: >
  Files GitHub follow-up issues so nothing gets lost after a PR. Use after /open-pr
  to capture TODOs, FIXMEs, and out-of-scope spec items before context is lost.
  Presents candidates for confirmation, then creates issues via gh CLI and links
  them back to the open PR.
---

# Open Issues

Find follow-up work items and file them as GitHub issues so nothing gets lost.

## When to invoke

- After `/open-pr` (to capture known gaps before context is lost)
- Any time you want to surface and track TODOs in the current branch

## What this skill does

1. Scans the diff for `TODO`, `FIXME`, `HACK`, `NOTE:`, `XXX` comments
2. Reads the spec's "Out of Scope" section if it exists
3. Presents a candidate list for you to confirm/edit/discard
4. Files confirmed items as GitHub issues with label `follow-up`
5. Links issues back to the open PR as a comment (if PR exists)

## Instructions for Claude

When this skill is invoked:

1. Collect candidates from two sources:

   **Source A — Code comments in the diff:**
   Run `git diff origin/main...HEAD` (or `git diff HEAD` if no origin) and extract lines matching:
   - `TODO`, `FIXME`, `HACK`, `XXX`, `NOTE:` (case-insensitive)
   - Include the file path and line number

   **Source B — Spec out-of-scope items:**
   If a spec file exists (`.anj-skills/specs/*.md` or `spec.md`), read the "Out of Scope" section and extract each bullet as a candidate issue.

2. Deduplicate and present the candidate list:
   ```
   Found N follow-up candidates:

   [1] file.ts:42 — TODO: add retry logic for network failures
   [2] file.ts:88 — FIXME: handle edge case when list is empty
   [3] spec.md (out of scope) — Pagination support for large datasets

   For each item, confirm: (y)es file it, (n)o skip, (e)dit title/description
   ```

3. For each confirmed item, file the issue:
   ```
   gh issue create \
     --title "<title>" \
     --body "<body>" \
     --label "follow-up"
   ```

   Issue body template:
   ```markdown
   ## Context
   Identified during implementation of <PR title or branch name>.

   ## Description
   <Expanded description from TODO comment or spec item>

   ## Source
   - File: `<file>:<line>` (if from code comment)
   - Related PR: #<PR number> (if open)
   ```

4. If a PR is open (`gh pr view --json number` succeeds), post a comment listing all filed issues:
   ```
   gh pr comment <PR-number> --body "Follow-up issues filed: #N1, #N2, #N3"
   ```

5. Print a summary:
   ```
   Filed N issues: #101, #102, #103
   Skipped N items.
   ```
