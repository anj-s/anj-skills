---
name: open-pr
description: >
  Creates a GitHub PR with a structured description. Use after /review returns no
  blockers.
parameters:
  draft:
    type: boolean
    description: Whether to create the PR as a draft.
    default: false
  title:
    type: string
    description: Explicit title for the PR. If not provided, it will be generated.
    required: false
---

# Open PR

Creates a GitHub pull request with a well-structured description, linking related issues and setting reviewers automatically.

**Prerequisites**: Tests pass, review has no blockers, branch is pushed to origin.

## When to invoke

- After `/review` returns "READY TO PR".

## What this skill does

1. Verifies the branch is pushed (`git status` + `git push` if needed).
2. Generates a PR description from commits and spec.
3. Scans commits for issue references (`#NNN`, `closes #NNN`, `fixes #NNN`).
4. Sets reviewers from `.github/CODEOWNERS` if it exists.
5. Creates the PR via `gh pr create`.
6. Prints the PR URL.

## PR Description Template

```markdown
## Summary
- <bullet 1>
- <bullet 2>
- <bullet 3>

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactor
- [ ] Documentation
- [ ] Breaking change

## Related Issues
Closes #NNN

## Test Plan
- [ ] Unit tests pass (`npm test` / `pytest` / etc.)
- [ ] Manually verified: <brief description of what you tested>

## Notes for Reviewer
<Any context that isn't obvious from the code or commit messages>
```

## Instructions for Claude

When this skill is invoked:

1. **Branch Hygiene**:
   - Run `git status` — if there are uncommitted changes, warn and ask if they should be committed first.
   - Run `git log origin/HEAD..HEAD --oneline` — if empty, warn that no commits are ahead of origin.
   - Check if branch is pushed: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. If error, push with `git push -u origin HEAD`.

2. **Metadata Generation**:
   - **Title**: If `title` is provided, use it. Otherwise, generate one from the most descriptive commit message. Keep under 72 characters.
   - **Summary**: Summarize key changes from `git log origin/HEAD..HEAD --format="%s %b"`. Reference `spec.md` if available.
   - **Type of Change**: Detect from diff and commits.
   - **Related Issues**: Scan for `#\d+`, `closes #\d+`, etc. Ask user for any missing ones.

3. **Reviewer Assignment**:
   - Look for `.github/CODEOWNERS`.
   - If found, extract owners for changed files and add to `gh` command.

4. **Review & Confirm**: Show the full PR description to the user and ask for confirmation.

5. **PR Creation**:
   - Run:
     ```bash
     gh pr create \
       --title "<title>" \
       --body "<description>" \
       [--draft] \
       [--reviewer <owner1,owner2>]
     ```
   - If `gh` command fails (e.g., auth error, no upstream), report clearly.

6. **Next Steps**:
   - Print the PR URL.
   - Print: "PR opened. Run /open-issues to file follow-up issues, or /verify-ci to track CI status."
