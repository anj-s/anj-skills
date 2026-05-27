---
name: tree
description: >
  Visualizes the directory structure with file metadata. Use to understand
  project layout, locate large files, or identify recently modified areas.
parameters:
  path:
    type: string
    description: The root directory to start from.
    default: .
  depth:
    type: integer
    description: How many levels deep to go.
    default: 2
  show_size:
    type: boolean
    description: Whether to show file sizes.
    default: false
---

# Tree

Visualize your project's structure and navigate complex directories with ease.

## When to invoke

- Getting an overview of a new codebase.
- Finding where specific modules or components live.
- Identifying large files or deep directory structures that might need cleanup.

## What this skill does

1. Generates an ASCII tree of the directory structure.
2. Optionally includes file size information.
3. Provides a summary of the contents (total files, total directories).

## Instructions for Claude

When this skill is invoked:

1. **Exploration**: Use `run_shell_command` with `find`, `ls -R`, or `tree` (if available) to gather directory structure.
2. **Formatting**:
   - Construct a clean ASCII tree representation.
   - Limit the depth based on the `depth` parameter.
   - If `show_size` is true, include human-readable sizes (e.g., 1.2MB, 4KB).
3. **Summarization**:
   - Count the total number of files and directories visited.
   - Highlight any particularly large files (e.g., > 1MB) if `show_size` is enabled.
4. **Output**:
   - Print the tree.
   - Print the summary.
5. **Contextual awareness**: If the user is looking for something specific (e.g., "where are the tests?"), highlight relevant directories in the output.
