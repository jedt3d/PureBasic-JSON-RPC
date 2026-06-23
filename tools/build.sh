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

codec_src="$ROOT/examples/002-transport-codecs/stdio_codec_probe.pb"
codec_out_dir="$ROOT/.build/examples/002-transport-codecs"
codec_out="$codec_out_dir/stdio_codec_probe"

connection_src="$ROOT/examples/003-connection-lifecycle/connection_probe.pb"
connection_out_dir="$ROOT/.build/examples/003-connection-lifecycle"
connection_out="$connection_out_dir/connection_probe"

protocol_src="$ROOT/examples/004-protocol-errors/spec_examples_probe.pb"
protocol_out_dir="$ROOT/.build/examples/004-protocol-errors"
protocol_out="$protocol_out_dir/spec_examples_probe"

dispatch_src="$ROOT/examples/005-dispatch/dispatch_probe.pb"
dispatch_out_dir="$ROOT/.build/examples/005-dispatch"
dispatch_out="$dispatch_out_dir/dispatch_probe"

outbound_src="$ROOT/examples/006-outbound-requests/outbound_probe.pb"
outbound_out_dir="$ROOT/.build/examples/006-outbound-requests"
outbound_out="$outbound_out_dir/outbound_probe"

mkdir -p "$foundation_out_dir" "$framing_out_dir" "$codec_out_dir" "$connection_out_dir" "$protocol_out_dir" "$dispatch_out_dir" "$outbound_out_dir"

"$PB_COMPILER" "$foundation_src" --console --thread --output "$foundation_out"
printf 'Built console scenario: %s\n' "$foundation_out"

"$PB_COMPILER" "$framing_src" --console --thread --output "$framing_out"
printf 'Built framing scenario: %s\n' "$framing_out"

"$PB_COMPILER" "$codec_src" --console --thread --output "$codec_out"
printf 'Built stdio codec scenario: %s\n' "$codec_out"

"$PB_COMPILER" "$connection_src" --console --thread --output "$connection_out"
printf 'Built connection scenario: %s\n' "$connection_out"

"$PB_COMPILER" "$protocol_src" --console --thread --output "$protocol_out"
printf 'Built protocol errors scenario: %s\n' "$protocol_out"

"$PB_COMPILER" "$dispatch_src" --console --thread --output "$dispatch_out"
printf 'Built dispatch scenario: %s\n' "$dispatch_out"

"$PB_COMPILER" "$outbound_src" --console --thread --output "$outbound_out"
printf 'Built outbound requests scenario: %s\n' "$outbound_out"
