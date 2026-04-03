---
name: memory
description: >
  Saves and recalls context so nothing important gets lost. Use /memory save to
  capture a decision, blocker, or lesson; use /memory recall at the start of a
  session to reload context. Short-term tier tracks the current session; long-term
  tier persists architecture decisions and lessons learned across sessions in git.
---

# Memory

Save and recall context so nothing important gets lost between sessions or across projects.

## Two tiers

| Tier | Scope | File | Use for |
|---|---|---|---|
| **Short-term** | Current session | `.anj-skills/memory/session.md` | Active task, decisions made today, open questions |
| **Long-term** | Persistent | `.anj-skills/memory/long-term.md` | Architecture decisions, lessons learned, project conventions |

Both files live in `.anj-skills/memory/` in the current project repo. They're checked in to git, so they're versioned alongside the code.

## Sub-commands

- `/memory save <note>` — save a note (skill decides short vs. long-term based on content)
- `/memory save-session <note>` — explicitly save to short-term
- `/memory save-long <note>` — explicitly save to long-term
- `/memory recall` — print relevant memory for the current task/context
- `/memory recall-all` — print all memory (both tiers)
- `/memory clear-session` — clear short-term memory (start of new session)
- `/memory list` — show all long-term entries with dates

## Short-term memory format (`session.md`)

```markdown
# Session Memory
Last updated: <ISO timestamp>

## Current Task
<What is being worked on right now>

## Decisions Made This Session
- <decision> (reason: <why>)

## Blockers / Open Questions
- [ ] <question or blocker>

## Context
<Any other relevant session state>
```

This file is **overwritten** (not appended) when you save session memory, keeping it current.

## Long-term memory format (`long-term.md`)

```markdown
# Long-Term Memory

## Architecture Decisions
<!-- [YYYY-MM-DD] decision: why -->
- [2025-06-15] Chose Vitest over Jest: faster, native ESM, no config overhead

## Lessons Learned
<!-- [YYYY-MM-DD] what happened and what to do instead -->
- [2025-06-20] Forgetting to update snapshots after schema changes caused CI failures. Always run /review before /open-pr.

## Project Conventions
<!-- stable facts about this codebase -->
- Auth tokens are stored in keychain, never env vars
- All async functions must handle SIGINT cleanup

## Recurring Mistakes to Avoid
- Debug logs left in after feature work (#2030 pattern)
- Checking conditions solely for logging (#6503 pattern)
```

Long-term entries are **appended** with timestamps, never overwritten.

## Instructions for Claude

When this skill is invoked:

### `/memory save <note>`
1. Classify the note:
   - **Short-term**: mentions "today", "this session", "currently", "working on", "blocked by", or is a decision with immediate context
   - **Long-term**: mentions "always", "never", "convention", "decided to", "learned", "architecture", or is a reusable fact
2. If ambiguous, ask: "Should this be short-term (this session) or long-term (keep forever)?"
3. Write to the appropriate file. For short-term: update the relevant section. For long-term: append with `[YYYY-MM-DD]` timestamp.
4. Confirm: "Saved to [short-term / long-term] memory."

### `/memory recall`
1. Read `session.md` if it exists.
2. Read `long-term.md` if it exists.
3. Look at `git log -1 --format="%s"` and current branch name to understand context.
4. Print relevant sections — don't dump everything, filter to what's applicable to the current task.
5. If no memory files exist: "No memory saved yet for this project. Use /memory save to start."

### `/memory recall-all`
Print both files in full.

### `/memory clear-session`
Overwrite `session.md` with a blank template. Confirm: "Session memory cleared."

### `/memory list`
Print all long-term entries with their dates, one per line. Group by section.

### File management
- Create `.anj-skills/memory/` if it doesn't exist.
- Stage and commit memory files after each save: `git add .anj-skills/memory/ && git commit -m "memory: update <short/long>-term notes"`
- If in a worktree, the memory is scoped to that branch's context.
