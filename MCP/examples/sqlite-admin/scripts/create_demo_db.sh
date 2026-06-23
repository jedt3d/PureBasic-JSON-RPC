#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../../../.." && pwd)"

"$ROOT/tools/build.sh"
"$ROOT/.build/MCP/examples/sqlite-admin/sqlite_admin_bootstrap" "${1:-}"
