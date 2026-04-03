# anj-skills

Personal workflow skills for AI coding agents. Covers the full development lifecycle — design through merge — and works with any agent that supports the [open skills standard](https://agentskills.io/specification).

## Skills

| Skill | When to use |
|---|---|
| [`/design`](#design) | Starting any non-trivial feature — before writing code |
| [`/implement`](#implement) | After design is done and you're on the right branch |
| [`/test`](#test) | After implementing, before review or PR |
| [`/review`](#review) | After tests pass, before opening a PR |
| [`/open-pr`](#open-pr) | After review returns no blockers |
| [`/open-issues`](#open-issues) | After opening a PR, to file follow-up items |
| [`/verify-ci`](#verify-ci) | After opening a PR, to confirm CI passes and branch is current |
| [`/project-status`](#project-status) | Start of session, standup, or when juggling multiple projects |
| [`/memory`](#memory) | Saving decisions and lessons; recalling context at session start |
| [`/setup-gh-git`](#setup-gh-git) | New environment, credential expiry, or broken gh auth |
| [`/sync-skills`](#sync-skills) | New project repo, or when skills may be stale |
| [`/uninstall-agent-skills`](#uninstall-agent-skills) | Periodic hygiene, after onboarding a new agent, or any time an agent may have installed skills without asking |

### Typical workflow

```
/design → /implement → /test → /review → /open-pr → /open-issues → /verify-ci
```

---

## Installation

Skills live in `~/anj-skills/` as the single source of truth. Each project gets a `.anj-skills/` directory with symlinks pointing there — so one `git pull` propagates updates everywhere.

### 1. Clone this repo

```bash
git clone https://github.com/anj-s/anj-skills.git ~/anj-skills
```

### 2. Link skills into a project

Run this once per project repo. From inside the project directory:

```bash
mkdir -p .anj-skills
for skill in ~/anj-skills/*/; do
  name=$(basename "$skill")
  ln -sf "$HOME/anj-skills/$name" ".anj-skills/$name"
done
```

Or invoke `/sync-skills` from your agent — it does the same thing interactively.

### 3. Set up auto-update (optional but recommended)

Add this to `~/.zshrc` or `~/.bashrc` so skills silently pull on every new terminal:

```bash
# Auto-sync anj-skills on new shell session
(git -C ~/anj-skills pull --ff-only --quiet 2>/dev/null &)
```

---

## Agent setup

Skills follow the [open skills standard](https://agentskills.io/specification) and work with any compatible agent. Reference them by path if your agent doesn't auto-discover `.anj-skills/`.

### Claude Code

Skills in `.anj-skills/` are auto-discovered. Invoke by name:

```
/design
/implement
```

### Cursor

Reference the skill file in chat:

```
@.anj-skills/design/SKILL.md
```

Or add to `.cursorrules`:

```
Skills are in .anj-skills/. Reference them by path when relevant.
```

### GitHub Copilot (VS Code)

Use the `#file` reference in Copilot Chat:

```
#file:.anj-skills/design/SKILL.md
```

### Gemini CLI

Pass the skill as context:

```bash
gemini --context .anj-skills/design/SKILL.md "design a new auth flow"
```

### Any other agent

Skills are plain markdown. Just tell your agent to read the file:

```
Follow the instructions in .anj-skills/design/SKILL.md
```

---

## Skill reference

### design

Produces a `spec.md` before any code is written. Iteratively clarifies requirements, edge cases, and acceptance criteria. Commits the spec to the current branch.

**Produces:** `.anj-skills/specs/<feature>.md`  
**Use before:** `/implement`

---

### implement

Reads the spec and decomposes it into a confirmed task checklist. Implements each task, runs lint and type-check, and commits after every step. Assumes you are already checked out on the correct branch in a worktree.

**Requires:** spec.md from `/design`, correct branch checked out  
**Use after:** `/design`  
**Use before:** `/test`

---

### test

Auto-detects the test framework (Jest, Vitest, pytest, go test, cargo test, etc.), runs the full suite, and reports pass/fail with coverage delta vs main. Attempts to fix failures up to 2 iterations before escalating.

**Use after:** `/implement`  
**Use before:** `/review`

---

### review

Full code review scoped to `git diff main...HEAD`. Runs a standard checklist (correctness, security, performance, test coverage) plus personalized checks for @anj-s (logging hygiene, snapshot sync, signal handling, execution mode consistency). Returns findings as blockers / warnings / suggestions.

**Use after:** `/test`  
**Use before:** `/open-pr`

---

### open-pr

Generates a PR title and structured description from commits and spec, scans commit messages for linked issue numbers, checks CODEOWNERS for reviewers, and opens the PR via `gh pr create`. Shows the draft for confirmation before submitting.

**Requires:** `gh` authenticated (run `/setup-gh-git` first)  
**Use after:** `/review` (no blockers)

---

### open-issues

Scans the diff for `TODO`, `FIXME`, `HACK`, `XXX` comments and the spec's "Out of Scope" section. Presents candidates for confirmation, then files each as a GitHub issue labeled `follow-up` and posts a summary comment on the open PR.

**Use after:** `/open-pr`

---

### verify-ci

Checks branch freshness vs `origin/main`, runs `gh pr checks` to get CI status, and shows failure logs for any failing checks. Issues a clear READY TO MERGE / NOT READY verdict.

**Use after:** `/open-pr`  
**Rerun:** whenever CI status changes

---

### project-status

Cross-project dashboard. Finds all git repos with activity in the last 30 days, shows current branch and last commit for each, and lists open PRs with CI check status and review state. Highlights what needs attention and ranks by priority.

**Use:** start of session, before standup, when context-switching between projects

---

### memory

Two-tier memory stored in `.anj-skills/memory/` and committed to git.

- **Short-term** (`session.md`) — current task, decisions, blockers. Overwritten each session.
- **Long-term** (`long-term.md`) — architecture decisions, lessons learned, conventions. Append-only with timestamps.

Sub-commands: `save`, `save-session`, `save-long`, `recall`, `recall-all`, `clear-session`, `list`

---

### setup-gh-git

First-time or repair setup for `gh` CLI and `git`. Configures git globals (user, email, pull rebase, default branch, push auto-setup), authenticates `gh` to GitHub, and optionally sets up SSH. Interactive steps are flagged to run yourself with `!`.

**Run first** in any new environment before skills that use `gh` or `git push`.

---

### sync-skills

Pulls latest from `~/anj-skills` and symlinks all skills into `.anj-skills/` in the current project. Offers to install a shell hook (`~/.zshrc`) for automatic silent updates on every new terminal session.

**Run once per project** to set up `.anj-skills/`, then let the shell hook handle updates.

---

### uninstall-agent-skills

Scans all known skill directories (`.anj-skills/`, `~/.claude/skills/`, `.cursor/skills/`, `.agents/skills/`, etc.) and identifies skills that weren't installed by you. A skill is considered yours if it's a symlink into `~/anj-skills/`, committed to git under your email, or lives in `~/anj-skills/` itself. Everything else is flagged as agent-installed and presented for per-item confirmation before removal. Inspects commit authors, flags external URLs and shell commands in suspicious skills, and never batch-deletes.

**Run:** periodically, after onboarding a new agent, or any time an agent may have installed skills without asking.

---

## Requirements

- `git`
- `gh` (GitHub CLI) — required for `open-pr`, `open-issues`, `verify-ci`, `project-status`
- Run `/setup-gh-git` to configure both

## Format

Skills use the [open skills standard](https://agentskills.io/specification): a directory containing a `SKILL.md` with YAML frontmatter (`name`, `description`) and a markdown body. Compatible with Claude Code, Cursor, GitHub Copilot, Gemini CLI, Codex CLI, and 25+ other agents.
