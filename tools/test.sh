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
  set -- "$ROOT/tests/unit/000_project_foundation.pb" "$ROOT/tests/unit/001_framing.pb" "$ROOT/tests/unit/002_transport_codecs.pb" "$ROOT/tests/unit/003_connection_lifecycle.pb" "$ROOT/tests/unit/004_protocol_errors.pb" "$ROOT/tests/unit/005_dispatch.pb" "$ROOT/tests/unit/006_outbound_requests.pb" "$ROOT/tests/unit/007_timeout_housekeeping.pb" "$ROOT/tests/unit/008_batch_handling.pb" "$ROOT/tests/unit/009_cancellation.pb"
fi

"$PUREUNIT" --compiler "$PB_COMPILER" --verbose --report "$report_file" "$@"

printf 'PureUnit report: %s\n' "$report_file"
