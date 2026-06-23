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

timeout_src="$ROOT/examples/007-timeout-housekeeping/timeout_probe.pb"
timeout_out_dir="$ROOT/.build/examples/007-timeout-housekeeping"
timeout_out="$timeout_out_dir/timeout_probe"

batch_src="$ROOT/examples/008-batch-handling/batch_probe.pb"
batch_out_dir="$ROOT/.build/examples/008-batch-handling"
batch_out="$batch_out_dir/batch_probe"

cancel_src="$ROOT/examples/009-cancellation/cancel_probe.pb"
cancel_out_dir="$ROOT/.build/examples/009-cancellation"
cancel_out="$cancel_out_dir/cancel_probe"

diagnostics_src="$ROOT/examples/010-diagnostics/diagnostics_probe.pb"
diagnostics_out_dir="$ROOT/.build/examples/010-diagnostics"
diagnostics_out="$diagnostics_out_dir/diagnostics_probe"

stress_src="$ROOT/examples/011-stress-memory/stress_probe.pb"
stress_out_dir="$ROOT/.build/examples/011-stress-memory"
stress_out="$stress_out_dir/stress_probe"

stdio_runtime_src="$ROOT/examples/012-stdio-runtime-pump/stdio_runtime_probe.pb"
stdio_runtime_out_dir="$ROOT/.build/examples/012-stdio-runtime-pump"
stdio_runtime_out="$stdio_runtime_out_dir/stdio_runtime_probe"

mcp_lifecycle_src="$ROOT/examples/013-mcp-lifecycle/mcp_lifecycle_probe.pb"
mcp_lifecycle_out_dir="$ROOT/.build/examples/013-mcp-lifecycle"
mcp_lifecycle_out="$mcp_lifecycle_out_dir/mcp_lifecycle_probe"

mkdir -p "$foundation_out_dir" "$framing_out_dir" "$codec_out_dir" "$connection_out_dir" "$protocol_out_dir" "$dispatch_out_dir" "$outbound_out_dir" "$timeout_out_dir" "$batch_out_dir" "$cancel_out_dir" "$diagnostics_out_dir" "$stress_out_dir" "$stdio_runtime_out_dir" "$mcp_lifecycle_out_dir"

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

"$PB_COMPILER" "$timeout_src" --console --thread --output "$timeout_out"
printf 'Built timeout housekeeping scenario: %s\n' "$timeout_out"

"$PB_COMPILER" "$batch_src" --console --thread --output "$batch_out"
printf 'Built batch handling scenario: %s\n' "$batch_out"

"$PB_COMPILER" "$cancel_src" --console --thread --output "$cancel_out"
printf 'Built cancellation scenario: %s\n' "$cancel_out"

"$PB_COMPILER" "$diagnostics_src" --console --thread --output "$diagnostics_out"
printf 'Built diagnostics scenario: %s\n' "$diagnostics_out"

"$PB_COMPILER" "$stress_src" --console --thread --output "$stress_out"
printf 'Built stress memory scenario: %s\n' "$stress_out"

"$PB_COMPILER" "$stdio_runtime_src" --console --thread --output "$stdio_runtime_out"
printf 'Built stdio runtime scenario: %s\n' "$stdio_runtime_out"

"$PB_COMPILER" "$mcp_lifecycle_src" --console --thread --output "$mcp_lifecycle_out"
printf 'Built MCP lifecycle scenario: %s\n' "$mcp_lifecycle_out"
