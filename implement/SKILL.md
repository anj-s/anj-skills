---
name: implement
description: >
  Turns a spec into committed code one task at a time. Use after /design has
  produced a spec.md and you are already checked out on the correct branch.
  Decomposes the spec into a confirmed task list, implements each chunk, runs
  lint and type-check, and commits after every step.
---

# Implement

Turns a spec into committed code, one small task at a time.

**Prerequisite**: You are already in a git worktree on the correct branch. If not, set that up before invoking this skill.

## When to invoke

- After `/design` has produced a `spec.md`
- When you want structured, checkpoint-driven implementation

## What this skill does

1. Reads the spec (asks where it is if not found automatically)
2. Decomposes the spec into a numbered task checklist
3. Presents the checklist for your confirmation before starting
4. Implements each task, then:
   - Runs linter (auto-detected from project config)
   - Runs type-checker if applicable
   - Commits with message referencing the task (`impl: <task description>`)
5. Marks each task complete as it finishes
6. Prints a summary of all commits made

## Instructions for Claude

When this skill is invoked:

1. Look for a spec file: check `.anj-skills/specs/`, then `spec.md` in repo root, then ask the user to provide the path.

2. Read the spec and extract the Acceptance Criteria and Architecture sections.

3. Decompose into an implementation task checklist. Each task should be:
   - Small enough to implement and commit in one step (roughly 10-50 lines of code)
   - Independently verifiable
   - Ordered by dependency (foundational work first)

   Print the checklist and ask: "Does this task breakdown look right? Any changes before I start?"

4. Wait for confirmation, then implement tasks one by one:

   For each task:
   a. Announce: "Starting task N: <description>"
   b. Write/edit the necessary code
   c. Run linter — detect from: `package.json` scripts (`lint`, `eslint`), `Makefile` (`make lint`), `.pre-commit-config.yaml`, or `pyproject.toml` (`ruff`, `flake8`)
   d. Run type-checker if present: `tsc --noEmit`, `mypy`, `pyright`
   e. Fix any lint/type errors before committing
   f. Commit: `git add -p` (stage only task-relevant files), then `git commit -m "impl: <task description>"`
   g. Mark task complete: "✓ Task N done"

5. After all tasks:
   - Print list of all commits made (`git log --oneline origin/HEAD..HEAD`)
   - Print: "Implementation complete. Run /test to verify, then /review before opening a PR."

6. If a task fails (lint errors you can't fix, test failures introduced):
   - Stop and report the blocker clearly
   - Do not commit broken code
   - Ask the user how to proceed
