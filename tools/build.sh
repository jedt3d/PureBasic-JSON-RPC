#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"

pb_prepare_dirs
pb_create_local_homes
pb_require_tools

example_src="$ROOT/examples/000-project-foundation/console_probe.pb"
example_out_dir="$ROOT/.build/examples/000-project-foundation"
example_out="$example_out_dir/console_probe"

mkdir -p "$example_out_dir"

"$PB_COMPILER" "$example_src" --console --thread --output "$example_out"

printf 'Built console scenario: %s\n' "$example_out"
