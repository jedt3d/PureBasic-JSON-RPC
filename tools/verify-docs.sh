#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

failures=0

require_file() {
  path="$1"
  label="$2"

  if [ ! -f "$ROOT/$path" ]; then
    printf 'Missing %s: %s\n' "$label" "$path" >&2
    failures=$((failures + 1))
  fi
}

require_text() {
  path="$1"
  pattern="$2"
  label="$3"

  if ! grep -F "$pattern" "$ROOT/$path" >/dev/null; then
    printf 'Missing %s in %s: %s\n' "$label" "$path" "$pattern" >&2
    failures=$((failures + 1))
  fi
}

require_heading() {
  path="$1"
  heading="$2"
  label="$3"

  if ! grep "^## $heading\$" "$ROOT/$path" >/dev/null; then
    printf 'Missing %s in %s: ## %s\n' "$label" "$path" "$heading" >&2
    failures=$((failures + 1))
  fi
}

for example_dir in "$ROOT"/examples/[0-9][0-9][0-9]-*; do
  [ -d "$example_dir" ] || continue
  slug="$(basename -- "$example_dir")"
  number="$(printf '%s\n' "$slug" | sed 's/-.*//')"
  test_count="$(find "$ROOT/tests/unit" -maxdepth 1 -name "${number}_*.pb" -print | wc -l | tr -d ' ')"

  require_file "examples/$slug/README.md" "example README"
  require_file "API/$slug.md" "API page for $slug"
  require_heading "docs/milestones.md" "$slug" "milestone section for $slug"
  require_text "API/index.md" "($slug.md)" "API index entry for $slug"
  require_text "docs/api.md" "API/$slug.md" "docs API bridge entry for $slug"

  if [ "$test_count" -eq 0 ]; then
    printf 'Missing unit test file for numbered route %s: tests/unit/%s_*.pb\n' "$slug" "$number" >&2
    failures=$((failures + 1))
  fi
done

for api_page in "$ROOT"/API/[0-9][0-9][0-9]-*.md; do
  [ -f "$api_page" ] || continue
  slug="$(basename -- "$api_page" .md)"

  require_file "examples/$slug/README.md" "example README for API page $slug"
  require_heading "docs/milestones.md" "$slug" "milestone section for API page $slug"
  require_text "API/index.md" "($slug.md)" "API index entry for API page $slug"
  require_text "docs/api.md" "API/$slug.md" "docs API bridge entry for API page $slug"
done

for required_doc in \
  "harness" \
  "purebasic-project-files" \
  "project-request" \
  "guideline" \
  "milestones" \
  "release-notes" \
  "release-hardening-plan" \
  "release-quality-gates" \
  "release-checklist" \
  "jsonrpc-compliance-matrix" \
  "security-robustness" \
  "mcp-for-purebasic" \
  "tutorial-building-with-purebasic-jsonrpc" \
  "mcp-example-milestone-log" \
  "api" \
  "api-stability" \
  "jsonrpc-foundation-gap-plan"
do
  require_text "docs/index.md" "$required_doc" "Sphinx toctree entry"
done

for planned_round in \
  "027-release-quality-gates" \
  "028-compliance-matrix" \
  "029-negative-tests" \
  "030-stress-lifecycle" \
  "031-security-robustness" \
  "032-release-automation-polish"
do
  require_heading "docs/milestones.md" "$planned_round" "planned milestone section"
done

if [ "$failures" -ne 0 ]; then
  printf 'Documentation verification failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'Verified documentation route metadata for numbered milestones and Sphinx docs.\n'
