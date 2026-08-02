#!/usr/bin/env bash
set -euo pipefail

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to synchronize a dirty worktree." >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
git fetch origin

if [[ "$current_branch" == "main" ]]; then
  git pull --ff-only origin main
else
  git rebase origin/main
fi

echo "Synchronized $current_branch with origin/main."
