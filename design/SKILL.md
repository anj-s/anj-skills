---
name: design
description: >
  Produces a structured spec.md before any code is written. Use at the start of
  any non-trivial feature or change — when the problem feels fuzzy, requirements
  are unclear, or you want a written record of decisions. Covers requirements,
  architecture, edge cases, and testing strategy. Works with any coding agent.
---

# Design

Before writing any code, create a spec. This skill guides you through producing a `spec.md` that becomes the authoritative source of truth for the implementation.

## When to invoke

- Starting any non-trivial feature or change
- When the problem feels fuzzy and you want to think it through first
- Before handing off to `/implement`

## What this skill does

1. Asks you to describe the problem or feature in plain language
2. Iteratively refines requirements, asks clarifying questions about edge cases
3. Produces a `spec.md` with all sections filled in
4. Commits the spec on the current branch with message `spec: <feature-name>`

## spec.md structure

```markdown
# Spec: <feature name>

## Problem Statement
What problem does this solve? Why now?

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

## Architecture / Design
- Key components changed or created
- Data model changes (before/after if applicable)
- Integration points with existing code
- Sequence diagram or flow if helpful (plain text is fine)

## Edge Cases & Error Handling
- Edge case 1 → expected behavior
- Edge case 2 → expected behavior
- Error conditions and how they surface to the user

## Testing Strategy
- Unit tests: what to cover
- Integration tests: what to cover
- Manual verification steps

## Out of Scope
- Things explicitly NOT being done in this change

## Open Questions
- [ ] Question 1 (owner: ?, due: ?)
```

## Instructions for Claude

When this skill is invoked:

1. Ask the user to describe the feature or change in 1-3 sentences.
2. Ask targeted follow-up questions to surface edge cases, constraints, and success criteria. Focus on: What does "done" look like? What can go wrong? What's explicitly not changing?
3. Draft the full spec.md and show it to the user for review.
4. Iterate on the spec until the user confirms it's ready.
5. Write the spec to `.anj-skills/specs/<feature-slug>.md` (create the directory if needed) or `spec.md` in the repo root if `.anj-skills/` doesn't exist.
6. Run: `git add <spec-file> && git commit -m "spec: <feature-name>"`
7. Print: "Spec committed. Run /implement when ready."

Do not proceed to implementation. The spec is the deliverable.
