#!/usr/bin/env bash
set -euo pipefail

current_branch="$(git branch --show-current)"
if [[ -z "$current_branch" || "$current_branch" == "main" ]]; then
  echo "Refusing to publish directly from main." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit or stash all changes before publishing." >&2
  exit 1
fi

gh auth status
Rscript tests/run_tests.R
git push --set-upstream origin "$current_branch"

existing_pr="$(gh pr list --head "$current_branch" --state open --json url --jq '.[0].url // empty')"
if [[ -n "$existing_pr" ]]; then
  echo "$existing_pr"
else
  gh pr create --draft --fill --head "$current_branch"
fi
