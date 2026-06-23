#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"

pb_prepare_dirs
pb_create_local_homes
pb_require_tools

foundation_src="$ROOT/examples/000-project-foundation/console_probe.pb"
foundation_out_dir="$ROOT/.build/examples/000-project-foundation"
foundation_out="$foundation_out_dir/console_probe"

framing_src="$ROOT/examples/001-framing/framing_probe.pb"
framing_out_dir="$ROOT/.build/examples/001-framing"
framing_out="$framing_out_dir/framing_probe"

mkdir -p "$foundation_out_dir" "$framing_out_dir"

"$PB_COMPILER" "$foundation_src" --console --thread --output "$foundation_out"
printf 'Built console scenario: %s\n' "$foundation_out"

"$PB_COMPILER" "$framing_src" --console --thread --output "$framing_out"
printf 'Built framing scenario: %s\n' "$framing_out"
