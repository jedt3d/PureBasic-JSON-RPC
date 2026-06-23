#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"
. "$ROOT/tools/pbp-projects.sh"

PB_IDE="${PB_IDE:-$(CDPATH= cd -- "$PB_INSTALL_HOME/.." && pwd)/MacOS/PureBasic}"

pb_prepare_dirs
pb_create_local_homes
pb_require_tools

if [ ! -x "$PB_IDE" ]; then
  printf 'PureBasic IDE builder not found: %s\n' "$PB_IDE" >&2
  exit 1
fi

build_project_target() {
  project_file="$1"
  target_name="$2"
  expected_format="$3"
  output_path="$4"
  label="$5"

  project_path="$ROOT/$project_file"
  output_abs="$ROOT/$output_path"

  if [ ! -f "$project_path" ]; then
    printf 'Missing PureBasic project file: %s\n' "$project_file" >&2
    exit 1
  fi

  if ! grep "format exe=\"$expected_format\"" "$project_path" >/dev/null; then
    printf 'PureBasic project %s does not declare format exe="%s"\n' "$project_file" "$expected_format" >&2
    exit 1
  fi

  mkdir -p "$(dirname -- "$output_abs")"
  "$PB_IDE" --build "$project_path" --target "$target_name" --readonly --quiet
  printf 'Built %s: %s\n' "$label" "$output_abs"
}

pbp_each_project_target build_project_target
