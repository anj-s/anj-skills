---
name: design
description: >
  Produces a structured spec.md before any code is written. Use at the start of
  any non-trivial feature or change. Covers requirements, architecture, edge
  cases, and testing strategy.
parameters:
  feature_description:
    type: string
    description: A brief description of the feature or change.
    required: false
---

# Design

Before writing any code, create a spec. This skill guides you through producing a `spec.md` that becomes the authoritative source of truth for the implementation.

## When to invoke

- Starting any non-trivial feature or change.
- When the problem feels fuzzy and you want to think it through first.
- Before handing off to `/implement`.

## What this skill does

1. Asks you to describe the problem or feature in plain language.
2. Iteratively refines requirements, asks clarifying questions about edge cases.
3. Produces a `spec.md` with all sections filled in.
4. Commits the spec on the current branch with message `spec: <feature-name>`.

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

1. **Initial Requirement Gathering**: If `feature_description` is provided, use it as a starting point. Otherwise, ask the user to describe the feature or change in 1-3 sentences.
2. **Deep Dive**: Ask targeted follow-up questions to surface edge cases, constraints, and success criteria. Focus on:
   - What does "done" look like?
   - What can go wrong?
   - What's explicitly not changing?
   - Are there any performance or security implications?
3. **Drafting**: Draft the full `spec.md` based on the gathered information. Ensure all sections of the template are addressed.
4. **Review & Iterate**: Show the draft to the user. Iterate based on feedback until the user confirms it's ready.
5. **Persistence**:
   - Determine the target path: `.anj-skills/specs/<feature-slug>.md`.
   - Create parent directories if they don't exist.
   - Write the file.
6. **Git Operations**:
   - `git add <spec-file>`
   - `git commit -m "spec: <feature-name>"`
   - If git operations fail (e.g., no changes, merge conflict), inform the user and suggest manual resolution.
7. **Final Hand-off**: Print: "Spec committed at <path>. Run /implement when ready."
