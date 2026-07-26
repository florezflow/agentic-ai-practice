#!/usr/bin/env bash
#
# validate-version-sync.sh
#
# Every component (module or pattern) declares its version in three places:
#
#   metadata.json      { "version": { "major": 1, "minor": 0, "patch": 0 } }
#   <template>.bicep   metadata version = '1.0.0'
#   CHANGELOG.md       ## 1.0.0 - DD.MM.YYYY
#
# They drift constantly if nothing checks them, and a drifted version is worse than no
# version at all: it makes the changelog lie. This script fails the PR when they disagree.
#
# It validates every component in the repo, not just changed ones. The repo is small enough
# that this is cheap, and it means the check is deterministic — no dependency on how the PR
# branch was created or how deep the fetch was. Scale this to a changed-files diff only when
# the full sweep becomes slow.
#
set -uo pipefail

exit_code=0

fail() {
  # GitHub Actions renders this as an annotation on the offending file.
  printf '::error file=%s::%s\n' "$1" "$2"
  exit_code=1
}

ok() {
  printf '  ok  %s\n' "$1"
}

printf 'Checking version synchronisation across all components\n\n'

components=$(find modules patterns -name metadata.json -type f 2>/dev/null | sort)

if [ -z "$components" ]; then
  printf '::error::No metadata.json found under modules/ or patterns/ — nothing to validate.\n'
  exit 1
fi

for meta in $components; do
  dir=$(dirname "$meta")
  printf '%s\n' "$dir"

  # --- version from metadata.json -------------------------------------------------------
  meta_version=$(jq -r '
    if (.version.major? // null) == null then "MISSING"
    else "\(.version.major).\(.version.minor).\(.version.patch)"
    end' "$meta" 2>/dev/null || printf 'UNREADABLE')

  case "$meta_version" in
    MISSING|UNREADABLE|*null*)
      fail "$meta" "metadata.json must declare version.major, version.minor and version.patch"
      printf '\n'
      continue
      ;;
  esac
  ok "metadata.json declares $meta_version"

  # --- the component template -----------------------------------------------------------
  # Modules use main.bicep; patterns use <name>.bicep. Either way there is exactly one
  # template at the top level of the component directory.
  if [ -f "$dir/main.bicep" ]; then
    template="$dir/main.bicep"
  else
    template=$(find "$dir" -maxdepth 1 -name '*.bicep' -type f | sort | head -n 1)
    template_count=$(find "$dir" -maxdepth 1 -name '*.bicep' -type f | wc -l | tr -d ' ')
    if [ "$template_count" -ne 1 ]; then
      fail "$meta" "expected exactly one .bicep template next to metadata.json, found $template_count"
      printf '\n'
      continue
    fi
  fi

  # --- version declared in the template --------------------------------------------------
  template_version=$(sed -n "s/^metadata version[[:space:]]*=[[:space:]]*'\([^']*\)'.*/\1/p" "$template" | head -n 1)

  if [ -z "$template_version" ]; then
    fail "$template" "template does not declare \"metadata version = 'X.Y.Z'\""
  elif [ "$template_version" != "$meta_version" ]; then
    fail "$template" "metadata version = '$template_version' does not match metadata.json ($meta_version)"
  else
    ok "$(basename "$template") declares $template_version"
  fi

  # --- matching CHANGELOG entry ----------------------------------------------------------
  changelog="$dir/CHANGELOG.md"
  if [ ! -f "$changelog" ]; then
    fail "$meta" "CHANGELOG.md is missing"
  elif ! grep -qE "^## ${meta_version//./\\.}( |$)" "$changelog"; then
    fail "$changelog" "no '## $meta_version' heading — every version needs a changelog entry"
  else
    ok "CHANGELOG.md has an entry for $meta_version"
  fi

  printf '\n'
done

if [ "$exit_code" -ne 0 ]; then
  printf 'Version synchronisation FAILED. Fix the annotations above.\n'
  printf 'Reminder: bump metadata.json, the "metadata version" line, and CHANGELOG.md together.\n'
else
  printf 'All components are version-synchronised.\n'
fi

exit "$exit_code"
