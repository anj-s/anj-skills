---
name: sync-skills
description: >
  Keeps skills up to date across every project and every coding agent. Use when
  starting work in a new project repo, or when skills may be stale. Pulls latest
  from ~/anj-skills, symlinks all skills into .anj-skills/ in the current project,
  and installs a shell hook for automatic updates on every new terminal session.
---

# Sync Skills

Keep your skills up to date in any project, with any coding agent.

Skills live in `~/anj-skills/` as the single source of truth. Each project gets a `.anj-skills/` directory with symlinks pointing there. When you pull `~/anj-skills`, all projects see the update instantly.

## What this skill does

1. Pulls latest from `~/anj-skills`
2. Symlinks each skill into `.anj-skills/` in the current project
3. Sets up a shell hook so skills auto-update at the start of every shell session (agent-agnostic)

## Instructions for the coding agent

When this skill is invoked:

### Step 1: Pull latest skills

```bash
git -C ~/anj-skills pull --ff-only
```

If this fails (diverged, offline), print a warning and continue — stale skills are better than no skills.

Show what changed:
```bash
git -C ~/anj-skills log --oneline ORIG_HEAD..HEAD 2>/dev/null
```

### Step 2: Link skills into current project

Find the project root:
```bash
git rev-parse --show-toplevel 2>/dev/null || echo "$PWD"
```

Set `PROJECT_ROOT` to that path. Create `.anj-skills/` if needed:
```bash
mkdir -p "$PROJECT_ROOT/.anj-skills"
```

For each skill directory in `~/anj-skills/` (skip `.git`, `.claude`, hidden dirs):
```bash
for skill in ~/anj-skills/*/; do
  name=$(basename "$skill")
  target="$PROJECT_ROOT/.anj-skills/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$HOME/anj-skills/$name" ]; then
    echo "✓ $name (already linked)"
  else
    rm -rf "$target"
    ln -s "$HOME/anj-skills/$name" "$target"
    echo "→ linked $name"
  fi
done
```

### Step 3: Set up auto-sync (agent-agnostic shell hook)

The most universal approach is a shell function in `~/.zshrc` or `~/.bashrc` that pulls on new shell sessions. This works regardless of which coding agent is running.

Check if the hook is already installed:
```bash
grep -q "anj-skills pull" ~/.zshrc 2>/dev/null || grep -q "anj-skills pull" ~/.bashrc 2>/dev/null
```

If not installed, ask: "Add auto-sync to your shell config so skills update silently on every new session?"

If yes, detect shell (`echo $SHELL`) and append to the appropriate rc file:

**For zsh (`~/.zshrc`):**
```bash
cat >> ~/.zshrc << 'EOF'

# Auto-sync anj-skills on new shell session
(git -C ~/anj-skills pull --ff-only --quiet 2>/dev/null &)
EOF
```

**For bash (`~/.bashrc`):**
```bash
cat >> ~/.bashrc << 'EOF'

# Auto-sync anj-skills on new shell session
(git -C ~/anj-skills pull --ff-only --quiet 2>/dev/null &)
```

The `&` backgrounds the pull so it never slows down shell startup.

Tell the user: "Auto-sync added. Skills will update silently when you open a new terminal. To apply now without restarting: `! source ~/.zshrc`"

### Step 4: Optional — add .anj-skills to .gitignore

Ask: "Add `.anj-skills` to this project's `.gitignore`? (Say no if you want to commit the symlinks)"

If yes:
```bash
echo ".anj-skills" >> "$PROJECT_ROOT/.gitignore"
git -C "$PROJECT_ROOT" add .gitignore && git -C "$PROJECT_ROOT" commit -m "chore: ignore .anj-skills symlinks"
```

### Final output

```
✓ Skills synced from ~/anj-skills (@ <short-sha>)
✓ .anj-skills/ linked in <project-name>
✓ Auto-sync active (shell hook in ~/.zshrc)

Available skills:
  /design  /implement  /test  /review
  /open-pr  /open-issues  /verify-ci
  /project-status  /memory  /setup-gh-git  /sync-skills
```

## Using skills with different agents

Skills are plain markdown — any agent can read and follow them. Reference them by path:

| Agent | How to load a skill |
|---|---|
| Claude Code | `/design` (auto-discovered from `.anj-skills/`) |
| Cursor | `@.anj-skills/design/SKILL.md` in chat |
| Copilot Chat | Paste contents or `#file:.anj-skills/design/SKILL.md` |
| Gemini CLI | `--context .anj-skills/design/SKILL.md` |
| Any agent | "Follow the instructions in `.anj-skills/design/SKILL.md`" |
