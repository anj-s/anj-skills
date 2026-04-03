---
name: project-status
description: >
  Cross-project dashboard for orienting at the start of a work session or before
  a standup. Use when juggling multiple projects and you need to see where each
  one stands. Shows current branch, last commit, open PRs, CI check status, and
  what needs attention — ranked by priority.
---

# Project Status

A cross-project dashboard. Shows where each active project stands so you can context-switch efficiently.

## When to invoke

- At the start of a work session to orient yourself
- When checking in on multiple projects in parallel
- Before a standup or async status update

## What this skill does

1. Finds all local project repos
2. For each repo: shows branch, last commit, open PRs, CI status
3. Highlights what needs attention (failing CI, unresolved review comments, stale branches)

## Instructions for Claude

When this skill is invoked:

1. **Find local repos:**
   Check these locations in order:
   - `~/code/` or `~/projects/` or `~/dev/` (common project dirs)
   - Ask the user for their project root if none of the above exist
   - Find all subdirectories that are git repos: `find <root> -maxdepth 2 -name ".git" -type d`

   Limit to repos with activity in the last 30 days:
   `git -C <repo> log --since="30 days ago" --oneline -1`

2. **For each active repo, collect:**

   ```bash
   # Current branch
   git -C <repo> rev-parse --abbrev-ref HEAD

   # Last commit (age + message)
   git -C <repo> log -1 --format="%ar — %s"

   # Uncommitted changes
   git -C <repo> status --short | wc -l

   # Open PRs for this repo (requires gh)
   gh pr list --repo <owner>/<repo> --author "@me" --json number,title,url,reviewDecision,statusCheckRollup
   ```

3. **For each open PR, show:**
   - PR number and title
   - CI status: all green ✓, failing ✗, pending ⏳
   - Review status: approved ✓, changes requested ✗, awaiting review ⏳
   - Unresolved review comments count (if available)

4. **Format the dashboard:**

   ```
   ## Project Status — <date>

   ### repo-name
   Branch: feature/auth-refactor
   Last commit: 2 hours ago — impl: add OAuth token refresh
   Uncommitted changes: 3 files

   PR #142: "Add OAuth token refresh"
   CI:     ✓ build  ✓ test  ✗ lint
   Review: ⏳ awaiting review (0 comments)
   → Action needed: fix lint failure

   ---

   ### another-repo
   Branch: main
   Last commit: 3 days ago — chore: update deps
   Uncommitted changes: none

   No open PRs.

   ---

   ## Summary
   🔴 Needs attention: repo-name (failing CI)
   🟡 In progress: another-repo (no open PRs)
   ```

5. If `gh` is not authenticated or repo isn't on GitHub, skip the PR/CI section and note it.

6. Highlight the top priority item: "Start with: <repo-name> — <reason>"
