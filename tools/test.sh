#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"

pb_prepare_dirs
pb_create_local_homes
pb_require_tools

report_dir="$ROOT/.reports/pureunit"
report_file="$report_dir/index.html"
mkdir -p "$report_dir"

if [ "$#" -eq 0 ]; then
  set -- "$ROOT/tests/unit/000_project_foundation.pb" "$ROOT/tests/unit/001_framing.pb" "$ROOT/tests/unit/002_transport_codecs.pb" "$ROOT/tests/unit/003_connection_lifecycle.pb" "$ROOT/tests/unit/004_protocol_errors.pb" "$ROOT/tests/unit/005_dispatch.pb" "$ROOT/tests/unit/006_outbound_requests.pb" "$ROOT/tests/unit/007_timeout_housekeeping.pb" "$ROOT/tests/unit/008_batch_handling.pb" "$ROOT/tests/unit/009_cancellation.pb" "$ROOT/tests/unit/010_diagnostics.pb" "$ROOT/tests/unit/011_stress_memory.pb" "$ROOT/tests/unit/012_stdio_runtime_pump.pb" "$ROOT/tests/unit/013_mcp_lifecycle.pb" "$ROOT/tests/unit/014_mcp_tools_registry.pb" "$ROOT/tests/unit/015_mcp_tools_call.pb" "$ROOT/tests/unit/016_packaging_docs.pb" "$ROOT/tests/unit/017_reader_writer_interfaces.pb" "$ROOT/tests/unit/018_byte_buffer_framing.pb" "$ROOT/tests/unit/019_connection_events.pb" "$ROOT/tests/unit/020_handler_registration_lifecycle.pb" "$ROOT/tests/unit/021_handler_cancellation_tokens.pb" "$ROOT/tests/unit/022_write_queue_close_semantics.pb" "$ROOT/tests/unit/023_trace_logger_hooks.pb" "$ROOT/tests/unit/024_compliance_suite.pb" "$ROOT/tests/unit/025_public_api_review.pb" "$ROOT/tests/unit/026_alpha_release_package.pb" "$ROOT/tests/unit/mcp_purebasic_check.pb" "$ROOT/tests/unit/mcp_sqlite_admin.pb"
fi

"$PUREUNIT" --compiler "$PB_COMPILER" --verbose --report "$report_file" "$@"

printf 'PureUnit report: %s\n' "$report_file"
