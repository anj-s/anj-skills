---
name: setup-gh-git
description: >
  First-time or repair setup for gh CLI and git. Use in a new environment, after
  a credential expiry, or when gh auth breaks. Configures git globals (user, email,
  pull strategy, default branch), authenticates gh to GitHub, and optionally sets
  up SSH. Required before any skill that uses gh or git push.
---

# Setup gh + git

First-time or repair setup for `gh` (GitHub CLI) and `git`. Run this in any new environment or when auth breaks.

## What this skill does

1. Verifies `gh` and `git` are installed
2. Configures git globals (user.name, user.email, pull strategy, default branch)
3. Authenticates `gh` to GitHub
4. Verifies the connection works
5. Optionally configures SSH key for git over SSH

## Instructions for Claude

When this skill is invoked:

### Step 1: Check installs

```bash
which gh && gh --version
which git && git --version
```

If `gh` is missing:
- macOS: `brew install gh`
- Linux: guide to https://cli.github.com/manual/installation
- Windows: `winget install GitHub.cli`

If `git` is missing:
- macOS: `xcode-select --install`
- Linux: `apt install git` / `yum install git`

### Step 2: Configure git globals

Ask the user for the following if not already set:
- `git config --global user.name` — full name (e.g. "Anjali Smith")
- `git config --global user.email` — email matching their GitHub account

Then set sensible defaults (only if not already configured):
```bash
git config --global pull.rebase true           # rebase on pull, not merge
git config --global init.defaultBranch main    # new repos default to main
git config --global push.autoSetupRemote true  # auto set upstream on first push
git config --global core.autocrlf input        # normalize line endings (macOS/Linux)
git config --global fetch.prune true           # auto-prune deleted remote branches
```

Print a summary of the final git config:
```bash
git config --global --list
```

### Step 3: Authenticate gh

Check current auth status:
```bash
gh auth status
```

If already authenticated and token is valid → skip to Step 4.

If not authenticated:
```
Tell the user: "You need to log in to GitHub. Run this command yourself:
  ! gh auth login
Then select: GitHub.com → HTTPS → Yes (authenticate git) → Login with browser"
```

Wait for the user to confirm they've logged in, then verify:
```bash
gh auth status
```

If they prefer SSH, tell them:
```
  ! gh auth login --git-protocol ssh
```

### Step 4: Verify end-to-end

```bash
# Verify gh API access
gh api user --jq '.login'

# Verify git can talk to GitHub (using gh as credential helper)
gh auth setup-git
```

Print the authenticated username: "✓ Logged in as: <username>"

### Step 5: Optional — SSH key setup

Ask: "Do you want to set up SSH for git operations? (Recommended for speed and reliability)"

If yes:
1. Check for existing key: `ls ~/.ssh/id_ed25519.pub 2>/dev/null`
2. If no key exists:
   ```
   Tell user: "Run this to generate a key:
     ! ssh-keygen -t ed25519 -C '<their-email>' -f ~/.ssh/id_ed25519"
   ```
3. Add to GitHub:
   ```
   Tell user: "Run this to add the key to GitHub:
     ! gh ssh-key add ~/.ssh/id_ed25519.pub --title '<machine-name>'"
   ```
4. Test: `ssh -T git@github.com`

### Final output

```
✓ git configured
  user.name  = <name>
  user.email = <email>
  pull.rebase = true
  defaultBranch = main

✓ gh authenticated
  user = <github-username>
  protocol = https (or ssh)

✓ Setup complete. All workflow skills are ready to use.
```

**Note**: Commands that require interactive login (`gh auth login`, `ssh-keygen`) must be run by the user directly. Prefix them with `!` in the Claude Code prompt to run in-session: `! gh auth login`
