#!/usr/bin/env bash
# Extract inline #!sbdl declarations from source files and write a .sbdl output file.

set -euo pipefail

flavor=""
output="output.sbdl"
files=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flavor) flavor="$2"; shift 2 ;;
    --output|-o) output="$2"; shift 2 ;;
    *) files+=("$1"); shift ;;
  esac
done

if [[ ${#files[@]} -eq 0 ]]; then
  echo "Usage: $0 [--flavor <name>] [-o <output>] <input-files...>" >&2
  exit 1
fi

{
  printf '#!sbdl\n\n'
  if [[ -n "$flavor" ]]; then
    printf 'document-flavor is definition { description is "%s" }\n\n' "$flavor"
  fi
  for file in "${files[@]}"; do
    grep -h '#!sbdl ' "$file" | sed 's/.*#!sbdl //'
  done
} > "$output"

echo "Extracted SBDL declarations to $output"
