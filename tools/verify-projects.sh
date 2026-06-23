#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pbp-projects.sh"

seen_targets="$(mktemp)"
seen_projects="$(mktemp)"
trap 'rm -f "$seen_targets" "$seen_projects"' EXIT

verify_project_target() {
  project_file="$1"
  target_name="$2"
  expected_format="$3"
  output_path="$4"
  label="$5"

  project_path="$ROOT/$project_file"

  if [ ! -f "$project_path" ]; then
    printf 'Missing PureBasic project file for %s: %s\n' "$label" "$project_file" >&2
    exit 1
  fi

  if ! grep "target name=\"$target_name\"" "$project_path" >/dev/null; then
    printf 'Missing target "%s" in %s\n' "$target_name" "$project_file" >&2
    exit 1
  fi

  if ! grep "format exe=\"$expected_format\"" "$project_path" >/dev/null; then
    printf 'Missing format exe="%s" in %s\n' "$expected_format" "$project_file" >&2
    exit 1
  fi

  if ! grep "outputfile value=\"[^\"]*$(basename -- "$output_path")\"" "$project_path" >/dev/null; then
    printf 'Missing output path for %s in %s\n' "$label" "$project_file" >&2
    exit 1
  fi

  printf '%s:%s\n' "$project_file" "$target_name" >> "$seen_targets"
  printf '%s\n' "$project_file" >> "$seen_projects"
}

pbp_each_project_target verify_project_target

if [ ! -f "$ROOT/PureBasic-JSON-RPC.pbp" ]; then
  printf 'Missing root PureBasic project file: PureBasic-JSON-RPC.pbp\n' >&2
  exit 1
fi

for project_dir in "$ROOT"/examples/* "$ROOT"/MCP/examples/*; do
  [ -d "$project_dir" ] || continue
  find "$project_dir" -maxdepth 1 -name '*.pb' -print | while IFS= read -r source_file; do
    project_count="$(find "$project_dir" -maxdepth 1 -name '*.pbp' -print | wc -l | tr -d ' ')"
    if [ "$project_count" -eq 0 ]; then
      printf 'PureBasic source has no project file: %s\n' "${source_file#$ROOT/}" >&2
      exit 1
    fi
  done
done

sort -u "$seen_projects" >/dev/null
printf 'Verified PureBasic project metadata for %s targets.\n' "$(wc -l < "$seen_targets" | tr -d ' ')"
