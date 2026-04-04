#!/bin/bash

# PostToolUse hook: Run ESLint --fix on edited JS/TS/Vue files.
# Non-blocking — exits 0 on skip/success, exits 1 on failure (never exit 2).

INPUT=$(cat)

# Extract file_path from JSON using grep/sed (no jq dependency)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"//')

# Skip if no file path provided
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Skip if not a JS/TS/Vue file
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx|vue)$ ]]; then
  exit 0
fi

# Skip if the file is not inside the web/ directory
if [[ ! "$FILE_PATH" =~ /web/ ]]; then
  exit 0
fi

# Extract the path relative to the web/ directory
RELATIVE_PATH="${FILE_PATH#*/web/}"

# Resolve the project root (where web/ lives)
PROJECT_ROOT=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | sed 's/"cwd":"//;s/"//')
if [[ -z "$PROJECT_ROOT" ]]; then
  exit 0
fi

# Check if the web container is running
if ! docker compose -f "$PROJECT_ROOT/web/docker-compose.yml" ps --status running 2>/dev/null | grep -q "vue"; then
  exit 0
fi

# Run ESLint --fix on the specific file
cd "$PROJECT_ROOT/web" && docker compose exec -T vue sh -c "./node_modules/.bin/eslint --fix --no-warn-ignored '$RELATIVE_PATH'" 2>/dev/null

# Always exit 0 — never block Claude
exit 0