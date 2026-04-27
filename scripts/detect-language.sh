#!/usr/bin/env bash
set -euo pipefail

working_directory="${BELA_WORKING_DIRECTORY:-.}"
language_input="${BELA_LANGUAGE_INPUT:-auto}"
source_input="${BELA_SOURCE_INPUT:-}"

cd "$working_directory"

language=""

if [[ "$language_input" != "auto" ]]; then
  case "$language_input" in
    clojure|dotnet|java|ruby|typescript)
      language="$language_input"
      ;;
    *)
      echo "Unsupported BELA language: $language_input" >&2
      exit 1
      ;;
  esac
elif [[ -f deps.edn || -f project.clj ]]; then
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

source="${source_input:-${GITHUB_REPOSITORY:-unknown}}"

{
  echo "BELA_LANGUAGE=$language"
  echo "BELA_SOURCE=$source"
} >> "$GITHUB_ENV"

echo "language=$language" >> "$GITHUB_OUTPUT"
echo "Detected BELA language: $language"
