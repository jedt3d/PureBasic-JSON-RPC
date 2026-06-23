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
