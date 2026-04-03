---
name: review
description: >
  Full code review scoped to the diff vs main. Use after tests pass and before
  opening a PR. Combines a standard checklist (correctness, security, performance,
  testing) with personalized checks for @anj-s (logging hygiene, snapshot sync,
  signal handling). Returns a blocker/warning/suggestion report.
---

# Review

Full code review scoped to `git diff main...HEAD` (or the current staged changes if no PR branch).

This skill extends `personal-pr-reviewer` with a broader standard checklist, run together as one pass.

## When to invoke

- After `/test` passes
- Before `/open-pr`
- Any time you want a pre-commit or pre-PR sanity check

## What this skill does

1. Diffs current branch vs. `origin/main` (falls back to staged changes)
2. Runs through the full review checklist below
3. Reports findings grouped by severity: **blocker**, **warning**, **suggestion**
4. Blockers must be resolved before opening a PR

## Review Checklist

### Personalized checks (@anj-s history)

- **Logging hygiene**: No debug logs that are non-actionable or excessively verbose. No conditions checked solely for logging purposes.
  - *Ref*: #2030, #6503
- **Snapshot sync**: If prompts, tool schemas, or default settings changed → are Vitest `.test.ts.snap` files updated?
  - *Ref*: #12461
- **Docs alignment**: If `settingsSchema.ts` or tool logic changed → are `docs/` files updated?
  - *Ref*: #12905
- **Registry sync**: If tools were added/removed → are `ALL_BUILTIN_TOOL_NAMES` and other registries updated?
  - *Ref*: #21355
- **Redundant conditions**: No shadowed logic or overlapping `if` blocks making paths unreachable.
  - *Ref*: #21355
- **Execution mode consistency**: Changes that affect interactive mode also handled in non-interactive mode.
  - *Ref*: #5137
- **Signal handling**: `SIGINT` (Ctrl+C) respected in all execution paths touched.
  - *Ref*: #11478

### Correctness & Logic

- [ ] Implementation matches the spec / stated intent
- [ ] Business logic is correct for the requirements
- [ ] Edge cases from the spec are handled
- [ ] No off-by-one errors, null dereferences, or incorrect boolean logic

### Security

- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] Input validated at system boundaries (user input, external API responses)
- [ ] Auth/authorization checks in place where needed

### Performance

- [ ] No obvious N+1 query patterns
- [ ] Appropriate data structures for the access patterns
- [ ] No memory leaks or unbounded growth

### Testing

- [ ] New code has tests
- [ ] Tests cover the happy path and key edge cases
- [ ] No tests skipped or commented out to make the suite pass

### Maintainability

- [ ] Naming is clear and consistent with the codebase
- [ ] No unnecessary abstraction for one-time use
- [ ] Comments explain "why", not "what"
- [ ] No dead code added

### Style & Linting

- [ ] Passes linter (if not already run by `/test`)
- [ ] Consistent formatting
- [ ] Types complete (if typed language)

## Instructions for Claude

When this skill is invoked:

1. Run `git diff origin/main...HEAD` to get the diff. If that fails (no `origin/main`), use `git diff HEAD` (staged + unstaged).

2. For each changed file, work through the checklist above. Be concrete: cite the file name and line number for each finding.

3. Categorize findings:
   - **Blocker**: Must fix before opening PR (correctness bugs, security issues, missing required syncs)
   - **Warning**: Should fix but won't block (coverage gaps, style issues, non-critical logging)
   - **Suggestion**: Optional improvement (naming, refactor ideas)

4. Output format:
   ```
   ## Review Summary

   **Blockers** (N)
   - file.ts:42 — [personalized] Snapshot not updated after schema change

   **Warnings** (N)
   - file.ts:17 — Debug log on line 17 is non-actionable

   **Suggestions** (N)
   - file.ts:88 — Variable name `x` could be more descriptive

   ---
   Verdict: [READY TO PR / NEEDS FIXES]
   ```

5. If blockers exist: list what needs to change before proceeding to `/open-pr`.
6. If no blockers: print "✓ Review passed. Run /open-pr to create the pull request."
