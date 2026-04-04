#!/bin/bash

# PostToolUse hook: Run Laravel Pint on edited PHP files.
# Non-blocking — exits 0 on skip/success, exits 1 on failure (never exit 2).

INPUT=$(cat)

# Extract file_path from JSON using grep/sed (no jq dependency)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"//')

# Skip if no file path provided
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Skip if not a PHP file
if [[ ! "$FILE_PATH" =~ \.php$ ]]; then
  exit 0
fi

# Skip if the file is not inside the api/ directory
if [[ ! "$FILE_PATH" =~ /api/ ]]; then
  exit 0
fi

# Extract the path relative to the api/ directory
RELATIVE_PATH="${FILE_PATH#*/api/}"

# Resolve the project root (where api/ lives)
PROJECT_ROOT=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | head -1 | sed 's/"cwd":"//;s/"//')
if [[ -z "$PROJECT_ROOT" ]]; then
  exit 0
fi

# Check if Sail is running by looking for the container
if ! docker compose -f "$PROJECT_ROOT/api/docker-compose.yml" ps --status running 2>/dev/null | grep -q "laravel"; then
  exit 0
fi

# Run Pint on the specific file
cd "$PROJECT_ROOT/api" && ./vendor/bin/sail bin pint "$RELATIVE_PATH" --quiet 2>/dev/null

# Always exit 0 — never block Claude
exit 0