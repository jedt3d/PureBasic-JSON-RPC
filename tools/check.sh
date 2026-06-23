#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

"$ROOT/tools/discover-purebasic.sh"
"$ROOT/tools/test.sh"
"$ROOT/tools/build.sh"
"$ROOT/.build/examples/000-project-foundation/console_probe"
"$ROOT/.build/examples/001-framing/framing_probe"
"$ROOT/.build/examples/002-transport-codecs/stdio_codec_probe"
"$ROOT/.build/examples/003-connection-lifecycle/connection_probe"
"$ROOT/.build/examples/004-protocol-errors/spec_examples_probe"
"$ROOT/.build/examples/005-dispatch/dispatch_probe"
"$ROOT/.build/examples/006-outbound-requests/outbound_probe"
"$ROOT/.build/examples/007-timeout-housekeeping/timeout_probe"
"$ROOT/.build/examples/008-batch-handling/batch_probe"
"$ROOT/.build/examples/009-cancellation/cancel_probe"
"$ROOT/.build/examples/010-diagnostics/diagnostics_probe"
"$ROOT/.build/examples/011-stress-memory/stress_probe"
"$ROOT/.build/examples/012-stdio-runtime-pump/stdio_runtime_probe"
