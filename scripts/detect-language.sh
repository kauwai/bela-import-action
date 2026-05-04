#!/usr/bin/env bash
set -euo pipefail

working_directory="${BELA_WORKING_DIRECTORY:-.}"

cd "$working_directory"

language=""

if [[ -f deps.edn || -f project.clj ]]; then
  language="clojure"
elif [[ -f package.json ]]; then
  language="typescript"
elif [[ -f pom.xml || -f build.gradle || -f build.gradle.kts || -f gradlew ]]; then
  language="java"
elif [[ -f Gemfile ]]; then
  language="ruby"
elif compgen -G "*.sln" > /dev/null || compgen -G "*.csproj" > /dev/null; then
  language="dotnet"
else
  echo "Could not detect a supported BELA importer in $working_directory." >&2
  exit 1
fi

project_path="."
if [[ -n "${GITHUB_WORKSPACE:-}" ]]; then
  workspace="$(cd "$GITHUB_WORKSPACE" && pwd -P)"
  current_directory="$(pwd -P)"

  if [[ "$current_directory" == "$workspace" ]]; then
    project_path="."
  elif [[ "$current_directory" == "$workspace"/* ]]; then
    project_path="${current_directory#"$workspace"/}"
  fi
fi

repository="${GITHUB_REPOSITORY:-repo}"
if [[ "$project_path" == "." ]]; then
  source="$repository"
else
  source="$repository/$project_path"
fi

{
  echo "BELA_LANGUAGE=$language"
  echo "BELA_SOURCE=$source"
} >> "$GITHUB_ENV"

echo "language=$language" >> "$GITHUB_OUTPUT"
echo "Detected BELA language: $language"
