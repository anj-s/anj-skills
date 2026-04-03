---
name: test
description: >
  Runs the test suite and verifies coverage. Use after /implement completes or
  before opening a PR to confirm nothing is broken. Auto-detects the test framework,
  reports pass/fail with coverage delta vs main, and attempts to fix failures
  up to 2 iterations before escalating.
---

# Test

Run the test suite, surface failures, and verify coverage before moving to review.

## When to invoke

- After `/implement` completes
- Before opening a PR to confirm nothing is broken
- Anytime you want a quick health check

## What this skill does

1. Auto-detects the test framework and run command
2. Runs the full test suite
3. Reports pass/fail with coverage summary
4. On failure: diagnoses root cause, attempts a fix, re-runs (max 2 iterations)
5. Shows coverage delta vs. `origin/main` (or `origin/master`)
6. Issues a go/no-go verdict

## Framework detection

| Signal | Command |
|---|---|
| `package.json` `test` script | `npm test` or `yarn test` or `pnpm test` |
| `vitest.config.*` | `npx vitest run --coverage` |
| `jest.config.*` | `npx jest --coverage` |
| `pytest.ini` / `pyproject.toml [tool.pytest]` | `pytest --cov` |
| `Makefile` with `test` target | `make test` |
| `go.mod` | `go test ./...` |
| `Cargo.toml` | `cargo test` |

## Instructions for Claude

When this skill is invoked:

1. Detect the test framework using the signals above. If ambiguous, ask the user.

2. Run the test command. Capture stdout/stderr.

3. Parse results:
   - Total tests: passed / failed / skipped
   - Coverage percentage (overall and per changed file if available)
   - List of failing tests with error messages

4. If all tests pass:
   - Show coverage summary
   - Compare coverage to `origin/main` branch if possible (`git diff origin/main --stat` to know which files changed, then compare coverage for those files)
   - If coverage dropped on changed files, warn but don't block
   - Print: "✓ All tests pass. Coverage: X%. Ready for /review."

5. If tests fail:
   - Show each failing test with its error
   - Diagnose: is this a pre-existing failure or introduced by recent changes? (`git stash && <test command> && git stash pop` to check, only if safe)
   - Attempt to fix the failures — edit code or tests as appropriate
   - Re-run tests
   - If still failing after 2 attempts: stop, explain what you tried, and ask the user for guidance
   - Never mark tests as passing by skipping or commenting them out

6. Coverage thresholds (soft warnings, not hard blocks):
   - Overall coverage < 60%: warn
   - Coverage dropped > 5% on changed files: warn with details
