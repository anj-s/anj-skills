---
name: open-pr
description: >
  Creates a GitHub PR with a structured description. Use after /review returns no
  blockers. Auto-generates the PR body from commits and spec, scans for linked
  issue numbers, sets reviewers from CODEOWNERS, and opens the PR via gh CLI.
---

# Open PR

Creates a GitHub pull request with a well-structured description, linking related issues and setting reviewers automatically.

**Prerequisites**: Tests pass, review has no blockers, branch is pushed to origin.

## When to invoke

- After `/review` returns "READY TO PR"

## What this skill does

1. Verifies the branch is pushed (`git status` + `git push` if needed)
2. Generates a PR description from commits and spec
3. Scans commits for issue references (`#NNN`, `closes #NNN`, `fixes #NNN`)
4. Sets reviewers from `.github/CODEOWNERS` if it exists
5. Creates the PR via `gh pr create`
6. Prints the PR URL

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

1. Check branch status:
   - Run `git status` — if there are uncommitted changes, warn and ask if they should be committed first
   - Run `git log origin/HEAD..HEAD --oneline` — if empty, warn that no commits are ahead of origin
   - Run `git push` if branch isn't pushed yet (check with `git rev-parse --abbrev-ref --symbolic-full-name @{u}` — if error, push with `git push -u origin HEAD`)

2. Generate the PR title:
   - Use the most descriptive commit message, or
   - Ask the user for a title if commits are generic (e.g., "wip", "fix")
   - Keep under 72 characters

3. Generate the Summary bullets:
   - Summarize the key changes from `git log origin/HEAD..HEAD --format="%s %b"`
   - Read spec.md if it exists for higher-level context
   - Write 2-4 bullets describing what changed and why

4. Detect type of change from the diff and commits.

5. Find related issues:
   - Scan commit messages for `#\d+`, `closes #\d+`, `fixes #\d+`, `resolves #\d+`
   - Ask the user if there are additional issues to link

6. Check for reviewers:
   - Look for `.github/CODEOWNERS` — extract owners for changed files
   - If found, add `--reviewer <handles>` to the `gh` command

7. Show the full PR description to the user and ask: "Does this look right? Any changes?"

8. Run:
   ```
   gh pr create \
     --title "<title>" \
     --body "<description>" \
     [--reviewer <owner1,owner2>]
   ```

9. Print the PR URL returned by `gh pr create`.

10. Print: "PR opened. Run /open-issues to file follow-up issues, or /verify-ci to track CI status."
