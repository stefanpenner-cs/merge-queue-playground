#!/usr/bin/env bash

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this inside the git repository after the initial commit."
  exit 1
fi

base_branch="$(git branch --show-current)"

if [[ -z "$base_branch" ]]; then
  echo "Could not determine the current branch."
  exit 1
fi

current_branch="$base_branch"

create_branch() {
  local branch_name="$1"
  local file_name="$2"
  local token="$3"
  local message="$4"

  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    echo "Skipping existing branch $branch_name"
    return
  fi

  git switch -c "$branch_name" "$base_branch"
  printf '%s\n' "$token" > "queue/$file_name"
  git add "queue/$file_name"
  git commit -m "$message"
}

create_branch "demo/ok-1" "ok-1.txt" "alpha" "Add ok-1 queue token"
create_branch "demo/ok-2" "ok-2.txt" "beta" "Add ok-2 queue token"
create_branch "demo/collision-1" "collision-1.txt" "collision" "Add collision-1 queue token"
create_branch "demo/collision-2" "collision-2.txt" "collision" "Add collision-2 queue token"

git switch "$current_branch"

echo "Created demo branches from $base_branch:"
echo "  demo/ok-1"
echo "  demo/ok-2"
echo "  demo/collision-1"
echo "  demo/collision-2"
