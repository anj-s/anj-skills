---
name: personal-pr-reviewer
description:
  A personalized code review skill tailored for @anj-s. It checks for common
  mistakes and patterns based on historical PRs, focusing on logging,
  signal handling, and execution mode consistency.
---

# Personal PR Reviewer for @anj-s

This skill assists in reviewing code changes specifically for @anj-s, ensuring that
previous mistakes are not repeated and that code quality remains high.

## Core Review Focus Areas based on History

### 1. Logging and Debugging Hygiene
*   **Excessive Logging**: Check for debug logs that might be too verbose or not actionable.
    *   *Reference*: "Remove debug logs that are not actionable but numerous (#2030)"
*   **Condition Checks for Logging**: Ensure that conditions are not checked *solely* for the purpose of logging.
    *   *Reference*: "Remove checking for a condition just for logging (#6503)"

### 2. Synchronization & Integrity
*   **Snapshot Updates**: When modifying prompts, tool schemas, or default settings, ensure that corresponding Vitest snapshots (`.test.ts.snap`) are updated.
    *   *Reference*: "refactor: split core system prompt into multiple parts (#12461)"
*   **Documentation Alignment**: Verify that `docs/` (especially configuration and tool docs) match changes in `settingsSchema.ts` or tool logic.
    *   *Reference*: "Enable write_todo tool and fix output function schema (#12905)"
*   **Feature Flag Cleanup**: When adding or removing features (like the `tracker`), ensure that `ALL_BUILTIN_TOOL_NAMES` and other registries are synchronized to avoid orphaned tools.
    *   *Reference*: "fix: logic for task tracker strategy and remove tracker tools (#21355)"

### 3. Logic & Flow
*   **Redundant Conditions**: Watch for overlapping `if` blocks or shadowed logic that might make certain paths unreachable or confusing.
    *   *Reference*: "fix: logic for task tracker strategy and remove tracker tools (#21355)"
*   **Execution Mode Consistency**: Verify consistency across `interactive` and `non-interactive` modes.
    *   *Reference*: "Fix: Ensure that non interactive mode and interactive mode are calling the same entry points (#5137)"
*   **Signal Handling**: Ensure `SIGINT` (Ctrl+C) is respected in all execution contexts.
    *   *Reference*: "(fix): Respect ctrl+c signal for aborting execution in NonInteractive mode (#11478)"

## General Code Review Checklist

In addition to the personalized checks above, perform a standard code review:

### 1. Correctness & Logic
*   Does the code do what it claims to do?
*   Are there any obvious bugs?
*   Are edge cases handled?

### 2. Maintainability & Style
*   Is the code easy to understand?
*   Are variables and functions named clearly?
*   Does it follow the project's style guide (e.g., imports, formatting)?

### 3. Testing
*   Are there tests covering the new changes?
*   Do existing tests pass? (Suggest running `npm run test` if not already done).

## Usage Instructions

1.  **Invoke**: "Review my PR" or "Check my changes for mistakes".
2.  **Target**:
    *   If a PR URL/ID is provided, check out that PR.
    *   If no PR is provided, check the local git status (`git diff`, `git diff --staged`).
3.  **Report**: Provide a summary of findings, highlighting any violations of the "Core Review Focus Areas" first.
