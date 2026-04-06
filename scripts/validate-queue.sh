#!/usr/bin/env bash

set -euo pipefail

declare -A seen=()
status=0

if [[ ! -d queue ]]; then
  echo "queue/ directory is missing"
  exit 1
fi

shopt -s nullglob
files=(queue/*.txt)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No queue entries found."
  exit 0
fi

for file in "${files[@]}"; do
  token="$(tr -d '[:space:]' < "$file")"

  if [[ -z "$token" ]]; then
    echo "Empty token in $file"
    status=1
    continue
  fi

  if [[ ! "$token" =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid token '$token' in $file"
    status=1
    continue
  fi

  if [[ -n "${seen[$token]:-}" ]]; then
    echo "Duplicate token '$token' found in $file and ${seen[$token]}"
    status=1
    continue
  fi

  seen["$token"]="$file"
done

if [[ $status -eq 0 ]]; then
  echo "Queue validation passed."
fi

exit "$status"
