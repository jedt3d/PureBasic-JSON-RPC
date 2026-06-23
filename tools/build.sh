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

mcp_tools_list_src="$ROOT/examples/014-mcp-tools-registry/mcp_tools_list_probe.pb"
mcp_tools_list_out_dir="$ROOT/.build/examples/014-mcp-tools-registry"
mcp_tools_list_out="$mcp_tools_list_out_dir/mcp_tools_list_probe"

mcp_tools_call_src="$ROOT/examples/015-mcp-tools-call/mcp_tools_call_probe.pb"
mcp_tools_call_out_dir="$ROOT/.build/examples/015-mcp-tools-call"
mcp_tools_call_out="$mcp_tools_call_out_dir/mcp_tools_call_probe"

package_src="$ROOT/examples/016-packaging-docs/package_probe.pb"
package_console_src="$ROOT/examples/016-packaging-docs/console_template.pb"
package_shared_src="$ROOT/examples/016-packaging-docs/shared_library_template.pb"
package_app_src="$ROOT/examples/016-packaging-docs/app_template.pb"
package_out_dir="$ROOT/.build/examples/016-packaging-docs"
package_out="$package_out_dir/package_probe"
package_console_out="$package_out_dir/console_template"
package_shared_out="$package_out_dir/shared_library_template.dylib"
package_app_out="$package_out_dir/app_template"

io_src="$ROOT/examples/017-reader-writer-interfaces/io_probe.pb"
io_out_dir="$ROOT/.build/examples/017-reader-writer-interfaces"
io_out="$io_out_dir/io_probe"

byte_buffer_src="$ROOT/examples/018-byte-buffer-framing/byte_buffer_probe.pb"
byte_buffer_out_dir="$ROOT/.build/examples/018-byte-buffer-framing"
byte_buffer_out="$byte_buffer_out_dir/byte_buffer_probe"

events_src="$ROOT/examples/019-connection-events/events_probe.pb"
events_out_dir="$ROOT/.build/examples/019-connection-events"
events_out="$events_out_dir/events_probe"

handler_lifecycle_src="$ROOT/examples/020-handler-registration-lifecycle/handler_lifecycle_probe.pb"
handler_lifecycle_out_dir="$ROOT/.build/examples/020-handler-registration-lifecycle"
handler_lifecycle_out="$handler_lifecycle_out_dir/handler_lifecycle_probe"

cancellation_token_src="$ROOT/examples/021-handler-cancellation-tokens/cancellation_token_probe.pb"
cancellation_token_out_dir="$ROOT/.build/examples/021-handler-cancellation-tokens"
cancellation_token_out="$cancellation_token_out_dir/cancellation_token_probe"

write_queue_src="$ROOT/examples/022-write-queue-close-semantics/write_queue_probe.pb"
write_queue_out_dir="$ROOT/.build/examples/022-write-queue-close-semantics"
write_queue_out="$write_queue_out_dir/write_queue_probe"

trace_src="$ROOT/examples/023-trace-logger-hooks/trace_probe.pb"
trace_out_dir="$ROOT/.build/examples/023-trace-logger-hooks"
trace_out="$trace_out_dir/trace_probe"

compliance_src="$ROOT/examples/024-compliance-suite/compliance_probe.pb"
compliance_out_dir="$ROOT/.build/examples/024-compliance-suite"
compliance_out="$compliance_out_dir/compliance_probe"

api_review_src="$ROOT/examples/025-public-api-review/api_review_probe.pb"
api_review_out_dir="$ROOT/.build/examples/025-public-api-review"
api_review_out="$api_review_out_dir/api_review_probe"

mkdir -p "$foundation_out_dir" "$framing_out_dir" "$codec_out_dir" "$connection_out_dir" "$protocol_out_dir" "$dispatch_out_dir" "$outbound_out_dir" "$timeout_out_dir" "$batch_out_dir" "$cancel_out_dir" "$diagnostics_out_dir" "$stress_out_dir" "$stdio_runtime_out_dir" "$mcp_lifecycle_out_dir" "$mcp_tools_list_out_dir" "$mcp_tools_call_out_dir" "$package_out_dir" "$io_out_dir" "$byte_buffer_out_dir" "$events_out_dir" "$handler_lifecycle_out_dir" "$cancellation_token_out_dir" "$write_queue_out_dir" "$trace_out_dir" "$compliance_out_dir" "$api_review_out_dir"

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

"$PB_COMPILER" "$mcp_tools_list_src" --console --thread --output "$mcp_tools_list_out"
printf 'Built MCP tools list scenario: %s\n' "$mcp_tools_list_out"

"$PB_COMPILER" "$mcp_tools_call_src" --console --thread --output "$mcp_tools_call_out"
printf 'Built MCP tools call scenario: %s\n' "$mcp_tools_call_out"

"$PB_COMPILER" "$package_src" --console --thread --output "$package_out"
printf 'Built packaging docs scenario: %s\n' "$package_out"

"$PB_COMPILER" "$package_console_src" --console --thread --output "$package_console_out"
printf 'Built console template: %s\n' "$package_console_out"

"$PB_COMPILER" "$package_shared_src" --dylib "$package_shared_out" --thread
printf 'Built shared library template: %s\n' "$package_shared_out"

"$PB_COMPILER" "$package_app_src" --thread --output "$package_app_out"
printf 'Built app template: %s\n' "$package_app_out"

"$PB_COMPILER" "$io_src" --console --thread --output "$io_out"
printf 'Built reader writer interfaces scenario: %s\n' "$io_out"

"$PB_COMPILER" "$byte_buffer_src" --console --thread --output "$byte_buffer_out"
printf 'Built byte buffer framing scenario: %s\n' "$byte_buffer_out"

"$PB_COMPILER" "$events_src" --console --thread --output "$events_out"
printf 'Built connection events scenario: %s\n' "$events_out"

"$PB_COMPILER" "$handler_lifecycle_src" --console --thread --output "$handler_lifecycle_out"
printf 'Built handler registration lifecycle scenario: %s\n' "$handler_lifecycle_out"

"$PB_COMPILER" "$cancellation_token_src" --console --thread --output "$cancellation_token_out"
printf 'Built handler cancellation tokens scenario: %s\n' "$cancellation_token_out"

"$PB_COMPILER" "$write_queue_src" --console --thread --output "$write_queue_out"
printf 'Built write queue close semantics scenario: %s\n' "$write_queue_out"

"$PB_COMPILER" "$trace_src" --console --thread --output "$trace_out"
printf 'Built trace logger hooks scenario: %s\n' "$trace_out"

"$PB_COMPILER" "$compliance_src" --console --thread --output "$compliance_out"
printf 'Built compliance suite scenario: %s\n' "$compliance_out"

"$PB_COMPILER" "$api_review_src" --console --thread --output "$api_review_out"
printf 'Built public API review scenario: %s\n' "$api_review_out"
