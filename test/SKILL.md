---
name: test
description: >
  Runs the test suite and verifies coverage. Use after /implement completes or
  before opening a PR to confirm nothing is broken.
parameters:
  test_command:
    type: string
    description: Explicit test command to run. If not provided, it will be auto-detected.
    required: false
---

# Test

Run the test suite, surface failures, and verify coverage before moving to review.

## When to invoke

- After `/implement` completes.
- Before opening a PR to confirm nothing is broken.
- Anytime you want a quick health check.

## What this skill does

1. Auto-detects the test framework and run command.
2. Runs the full test suite.
3. Reports pass/fail with coverage summary.
4. On failure: diagnoses root cause, attempts a fix, re-runs (max 2 iterations).
5. Shows coverage delta vs. `origin/main` (or `origin/master`).
6. Issues a go/no-go verdict.

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

1. **Initialization**:
   - If `test_command` is provided, use it.
   - Otherwise, detect the test framework using the signals above. If ambiguous, ask the user.

2. **Execution**: Run the test command. Capture stdout/stderr. Ensure output is sufficient for diagnosis but not overwhelming.

3. **Analysis**:
   - Parse results: Total tests, passed, failed, skipped.
   - Extract coverage percentage (overall and per changed file).
   - Identify failing tests with specific error messages.

4. **Success Case**:
   - If all tests pass:
     - Show coverage summary.
     - Compare coverage to `origin/main` branch if possible.
     - If coverage dropped on changed files, warn but don't block.
     - Print: "✓ All tests pass. Coverage: X%. Ready for /review."

5. **Failure Case**:
   - Show each failing test with its error.
   - **Diagnosis**: Determine if the failure was introduced by recent changes. Use `git stash` safely if needed to check the previous state.
   - **Self-Correction**:
     - Attempt to fix failures (max 2 iterations).
     - After each fix, re-run tests.
     - If still failing after 2 attempts, stop, explain what you tried, and ask the user for guidance.
     - **Warning**: Do not mark tests as passing by skipping or commenting them out.

6. **Coverage Monitoring**:
   - Overall coverage < 60%: warn.
   - Coverage dropped > 5% on changed files: warn with details.
