---
name: review
description: >
  Full code review scoped to the diff vs main. Use after tests pass and before
  opening a PR.
parameters:
  base_branch:
    type: string
    description: The branch to compare against.
    default: origin/main
---

# Review

Full code review scoped to `git diff <base_branch>...HEAD`.

## When to invoke

- After `/test` passes.
- Before `/open-pr`.
- Any time you want a pre-commit or pre-PR sanity check.

## What this skill does

1. Diffs current branch vs. `base_branch` (falls back to staged changes).
2. Runs through the full review checklist.
3. Reports findings grouped by severity: **blocker**, **warning**, **suggestion**.
4. Blockers must be resolved before opening a PR.

## Review Checklist

### Personalized checks (@anj-s history)

- **Logging hygiene**: No debug logs that are non-actionable or excessively verbose. No conditions checked solely for logging purposes.
- **Snapshot sync**: If prompts, tool schemas, or default settings changed → are Vitest `.test.ts.snap` files updated?
- **Docs alignment**: If `settingsSchema.ts` or tool logic changed → are `docs/` files updated?
- **Registry sync**: If tools were added/removed → are `ALL_BUILT_TOOL_NAMES` and other registries updated?
- **Redundant conditions**: No shadowed logic or overlapping `if` blocks making paths unreachable.
- **Execution mode consistency**: Changes that affect interactive mode also handled in non-interactive mode.
- **Signal handling**: `SIGINT` (Ctrl+C) respected in all execution paths touched.

### Correctness & Logic

- [ ] Implementation matches the spec / stated intent.
- [ ] Business logic is correct for the requirements.
- [ ] Edge cases from the spec are handled.
- [ ] No off-by-one errors, null dereferences, or incorrect boolean logic.

### Security

- [ ] No SQL injection, XSS, or hardcoded secrets.
- [ ] Input validated at system boundaries.
- [ ] Auth/authorization checks in place where needed.

### Performance

- [ ] No obvious N+1 query patterns.
- [ ] Appropriate data structures for access patterns.
- [ ] No memory leaks or unbounded growth.

### Testing

- [ ] New code has tests.
- [ ] Tests cover happy path and key edge cases.
- [ ] No tests skipped or commented out.

### Maintainability

- [ ] Naming is clear and consistent.
- [ ] No unnecessary abstraction.
- [ ] Comments explain "why", not "what".
- [ ] No dead code added.

## Instructions for Claude

When this skill is invoked:

1. **Diff Generation**:
   - Run `git diff <base_branch>...HEAD` to get the diff.
   - If that fails, attempt `git diff origin/master...HEAD`.
   - If both fail, use `git diff HEAD` (staged + unstaged changes).
   - If the diff is empty, inform the user: "No changes detected to review."

2. **Checklist Execution**: For each changed file, work through the checklist. Be concrete: cite file name and line number for each finding.

3. **Classification**:
   - **Blocker**: Must fix before PR (bugs, security, missing syncs).
   - **Warning**: Should fix (coverage gaps, non-critical logging).
   - **Suggestion**: Optional improvement (naming, refactors).

4. **Structured Report**:
   ```
   ## Review Summary

   **Blockers** (N)
   - file.ts:42 — [Personalized] Snapshot not updated.

   **Warnings** (N)
   - file.ts:17 — Non-actionable debug log.

   **Suggestions** (N)
   - file.ts:88 — Suggest more descriptive variable name.

   ---
   Verdict: [READY TO PR / NEEDS FIXES]
   ```

5. **Outcome**:
   - If blockers exist: list required fixes before proceeding to `/open-pr`.
   - If no blockers: print "✓ Review passed. Run /open-pr to create the pull request."

6. **Error Handling**: If a file is too large to review in detail, summarize the changes and flag the limitation.
