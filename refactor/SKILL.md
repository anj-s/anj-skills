---
name: refactor
description: >
  Safely refactors code to improve structure, readability, or performance without
  changing behavior. Includes automated regression checks.
parameters:
  path:
    type: string
    description: File or directory to refactor.
    required: true
  goal:
    type: string
    description: The specific refactoring goal (e.g., 'extract method', 'rename variable').
    required: true
---

# Refactor

Improve your code's quality without breaking its functionality. This skill guides you through a disciplined refactoring process.

## When to invoke

- You see "smelly" code (long methods, complex logic, duplication).
- You want to modernize code (e.g., convert to async/await, use new language features).
- Preparing a codebase for a new feature.

## What this skill does

1. Analyzes the target code for refactoring opportunities.
2. Proposes a step-by-step refactoring plan.
3. Performs small, atomic changes.
4. Automatically runs tests after each change to ensure no regressions.
5. Commits each successful refactoring step.

## Instructions for Claude

When this skill is invoked:

1. **Analysis**:
   - Read the code at `path`.
   - Identify specific patterns that match the `goal`.
   - Check if there are existing tests for the code. **Warning**: If no tests exist, strongly recommend running `/test` to create them first.
2. **Planning**:
   - Create a sequence of atomic refactoring steps.
   - Show the plan to the user: "Here is my refactoring plan. Each step will be verified by tests."
3. **Execution Loop**:
   - For each step:
     a. Apply the change.
     b. Run relevant tests (use `/test`).
     c. If tests pass: commit the change (`refactor: <step description>`).
     d. If tests fail: revert the change and explain why.
4. **Finalization**:
   - Summarize the improvements (e.g., reduced complexity, improved readability).
   - Show the final state of the code.
5. **Safety Guardrails**:
   - Never combine behavior changes with refactoring.
   - If the refactoring becomes too complex, suggest breaking it into smaller sessions.
   - Always prioritize maintainability over cleverness.
