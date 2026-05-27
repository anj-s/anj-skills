---
name: memory
description: >
  Saves and recalls context so nothing important gets lost. Use /memory save to
  capture a decision, blocker, or lesson.
parameters:
  operation:
    type: string
    description: The sub-command to perform (save, recall, recall-all, clear-session, list).
    enum: [save, save-session, save-long, recall, recall-all, clear-session, list]
    default: recall
  note:
    type: string
    description: The note to save (for save operations).
    required: false
---

# Memory

Save and recall context so nothing important gets lost between sessions or across projects.

## Two tiers

| Tier | Scope | File | Use for |
|---|---|---|---|
| **Short-term** | Current session | `.anj-skills/memory/session.md` | Active task, decisions made today, open questions |
| **Long-term** | Persistent | `.anj-skills/memory/long-term.md` | Architecture decisions, lessons learned, project conventions |

## Sub-commands

- `/memory save <note>` — save a note (skill decides short vs. long-term based on content)
- `/memory save-session <note>` — explicitly save to short-term
- `/memory save-long <note>` — explicitly save to long-term
- `/memory recall` — print relevant memory for the current task/context
- `/memory recall-all` — print all memory (both tiers)
- `/memory clear-session` — clear short-term memory (start of new session)
- `/memory list` — show all long-term entries with dates

## Instructions for Claude

When this skill is invoked:

1. **Routing**: Based on the `operation` and `note`:
   - If `save*` and `note` is missing, ask the user for the content.
   - If `recall` or `recall-all`, perform retrieval.

2. **Classification (for `save`)**:
   - **Short-term**: mentions "today", "this session", "currently", "working on", "blocked by".
   - **Long-term**: mentions "always", "never", "convention", "architecture", "learned".
   - If ambiguous, ask: "Short-term or long-term?"

3. **Persistence**:
   - Create `.anj-skills/memory/` if needed.
   - **Short-term**: Update `session.md` (overwrite).
   - **Long-term**: Append to `long-term.md` with `[YYYY-MM-DD]` timestamp.
   - `git add .anj-skills/memory/ && git commit -m "memory: update <tier> notes"`.

4. **Retrieval (for `recall*`)**:
   - Read relevant files.
   - Filter content based on current git context (branch, last commit) to keep it concise.
   - If no memory: "No memory saved yet for this project."

5. **Maintenance**:
   - `clear-session`: Reset `session.md` to template.
   - `list`: Show all long-term entries grouped by section.
