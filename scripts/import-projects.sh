#!/usr/bin/env bash
set -euo pipefail

action_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=project-utils.sh
source "$action_dir/scripts/project-utils.sh"

root_directory="${BELA_WORKING_DIRECTORY:-.}"
root_directory="$(cd "$root_directory" && pwd -P)"
export GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-$root_directory}"

mapfile -t project_dirs < <(find_project_dirs "$root_directory")

if [[ "${#project_dirs[@]}" -eq 0 ]]; then
  echo "Could not detect a supported BELA importer in $root_directory or its child directories." >&2
  exit 1
fi

languages=()
sources=()

for project_dir in "${project_dirs[@]}"; do
  language="$(detect_project_language "$project_dir")"
  source_name="$(bela_project_source "$project_dir")"

  languages+=("$language")
  sources+=("$source_name")

  echo "Importing BELA project: $source_name ($language)"

  if [[ "${BELA_DRY_RUN:-false}" == "true" ]]; then
    continue
  fi

  BELA_WORKING_DIRECTORY="$project_dir" \
    BELA_LANGUAGE="$language" \
    BELA_SOURCE="$source_name" \
    "$action_dir/scripts/prepare.sh"

  BELA_WORKING_DIRECTORY="$project_dir" \
    BELA_LANGUAGE="$language" \
    BELA_SOURCE="$source_name" \
    "$action_dir/scripts/run-updater.sh"

  if [[ "${BELA_SKIP_UPLOAD:-false}" == "true" ]]; then
    ecd_file="$project_dir/.bela/bela-update.ecd"
    echo "Generated ECD: $ecd_file"
    sed -n '1,40p' "$ecd_file"
  else
    BELA_WORKING_DIRECTORY="$project_dir" \
      "$action_dir/scripts/upload.sh"
  fi
done

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    IFS=,
    echo "languages=${languages[*]}"
    echo "sources=${sources[*]}"
  } >> "$GITHUB_OUTPUT"
fi
