---
name: verify-ci
description: >
  Confirms a branch is merge-ready. Use after opening a PR or before requesting
  review. Checks that the branch is up to date with main, all GitHub CI checks
  pass, and there are no merge conflicts. Shows failing check logs and suggests
  fixes. Issues a clear READY / NOT READY verdict.
---

# Verify CI

Confirm the branch is merge-ready: up to date with main, all CI checks green, no merge conflicts.

## When to invoke

- After `/open-pr` to monitor CI status
- Before requesting review (to avoid wasting reviewer time)
- When CI is taking a while and you want a status snapshot

## What this skill does

1. Checks if the branch is up to date with `origin/main`
2. Runs `gh pr checks` to get CI status
3. Shows logs for any failing checks
4. Issues a merge-readiness verdict

## Instructions for Claude

When this skill is invoked:

1. **Check branch freshness:**
   ```
   git fetch origin main
   git merge-base --is-ancestor origin/main HEAD
   ```
   - Exit code 0 → branch includes all of main → up to date ✓
   - Exit code 1 → main has commits not in this branch → needs rebase

   If behind: show how many commits behind with `git log HEAD..origin/main --oneline`
   and print: "Branch is N commits behind main. Run `git rebase origin/main` to update."

2. **Check for merge conflicts (without merging):**
   ```
   git merge --no-commit --no-ff origin/main
   git merge --abort
   ```
   If conflicts detected, list the conflicting files.

3. **Get CI check status:**
   ```
   gh pr checks
   ```
   Parse output into:
   - ✓ passing checks
   - ✗ failing checks
   - ⏳ pending checks

4. For each failing check:
   - Get the log: `gh run view <run-id> --log-failed` (extract run ID from `gh pr checks` output)
   - Show the last 30 lines of the failure log
   - Suggest a fix if the error is recognizable (e.g., lint failure, test failure, type error)

5. Print the verdict:
   ```
   ## CI Status

   Branch freshness: ✓ Up to date with main  (or ✗ N commits behind)
   Merge conflicts:  ✓ None  (or ✗ Conflicts in: file1, file2)

   CI Checks:
   ✓ build (2m 14s)
   ✓ test (1m 42s)
   ✗ lint — see log below
   ⏳ e2e (running)

   ---
   Verdict: NOT READY — fix lint failure before merging
   ```

   Or if all clear:
   ```
   ---
   Verdict: ✓ READY TO MERGE — all checks pass, branch is up to date
   ```

6. If checks are still pending: print "Checks still running. Re-run /verify-ci in a few minutes."
