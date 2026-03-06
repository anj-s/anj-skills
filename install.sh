#!/bin/bash

# install.sh
# Usage: ./install.sh [target_dir]
# Defaults to linking skills into the current directory's .gemini/skills

TARGET="${1:-.gemini/skills}"

if [ ! -d "$TARGET" ]; then
    echo "Creating directory $TARGET..."
    mkdir -p "$TARGET"
fi

# Ensure absolute paths
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_ABS="$(cd "$TARGET" && pwd)"

echo "Installing skills from '$REPO_DIR' to '$TARGET_ABS'..."

found_skills=0
for skill_path in "$REPO_DIR"/*; do
    if [ -d "$skill_path" ] && [ -f "$skill_path/SKILL.md" ]; then
        skill_name=$(basename "$skill_path")
        
        # specific check to avoid recursive linking if run inside .gemini/skills
        if [ "$skill_path" == "$TARGET_ABS" ]; then continue; fi

        echo "  Linking skill: $skill_name"
        ln -sf "$skill_path" "$TARGET_ABS/$skill_name"
        found_skills=1
    fi
done

if [ $found_skills -eq 0 ]; then
    echo "No skills found in $REPO_DIR (looking for folders with SKILL.md)"
else
    echo "Done! Your personal skills are now active in this project."
fi
