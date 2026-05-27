---
name: regex
description: >
  Performs advanced regular expression operations across the codebase. Use for
  complex search and replace, data extraction, or validation of patterns.
parameters:
  pattern:
    type: string
    description: The regex pattern to search for.
    required: true
  replacement:
    type: string
    description: The replacement string (for replace operations).
    required: false
  glob:
    type: string
    description: Glob pattern to filter files (e.g., 'src/**/*.ts').
    required: false
  operation:
    type: string
    description: The operation to perform (search, replace, extract).
    enum: [search, replace, extract]
    default: search
---

# Regex

Perform advanced regular expression operations across your project. This skill leverages powerful search tools to help you find and modify code patterns safely.

## When to invoke

- Searching for complex code patterns that simple text search can't find.
- Performing bulk refactoring with capture groups and replacements.
- Extracting specific data from multiple files based on a pattern.

## What this skill does

1. Validates the provided regex pattern.
2. Performs the requested operation (search, replace, or extract).
3. Provides a preview for replace operations.
4. Executes changes and reports results.

## Instructions for Claude

When this skill is invoked:

1. **Validation**: Ensure the `pattern` is a valid regular expression.
2. **Search**:
   - If `operation` is `search`:
     - Use `grep_search` with the provided `pattern` and `glob` (if any).
     - Display matches with context.
3. **Replace**:
   - If `operation` is `replace`:
     - **Safety First**: First, perform a search to show the user what will be replaced.
     - Use `grep_search` to identify all occurrences.
     - For each occurrence, show the "Before" and "After" state using the `replacement`.
     - Ask for confirmation: "Shall I apply these N replacements?"
     - If confirmed, use `replace` or `run_shell_command` (e.g., `sed` or a python script) to apply changes.
     - **Validation**: After replacing, run a quick lint check if applicable.
4. **Extract**:
   - If `operation` is `extract`:
     - Use `grep_search` to find matches.
     - Extract specific capture groups if requested by the user.
     - Present the extracted data in a clean, structured format (e.g., a table or list).

5. **Error Handling**:
   - If the regex is invalid, explain why and suggest a fix.
   - If no matches are found, suggest broadening the pattern or checking the glob.
   - If a replacement fails, report exactly which file/line failed and why.
