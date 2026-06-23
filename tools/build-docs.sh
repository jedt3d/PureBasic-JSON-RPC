#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DOCS_VENV="$ROOT/.local/docs-venv"

if [ ! -x "$DOCS_VENV/bin/python" ]; then
  python3 -m venv "$DOCS_VENV"
fi

"$DOCS_VENV/bin/python" -m pip install --upgrade pip >/dev/null
"$DOCS_VENV/bin/python" -m pip install -r "$ROOT/docs/requirements.txt" >/dev/null

"$DOCS_VENV/bin/python" -m sphinx -W -b html "$ROOT/docs" "$ROOT/.build/docs-html"
"$DOCS_VENV/bin/python" "$ROOT/tools/build-doc-pdfs.py"

pdf_count="$(find "$ROOT/.build/docs-pdf" -maxdepth 1 -name '*.pdf' -print | wc -l | tr -d ' ')"
if [ "$pdf_count" != "2" ]; then
  printf 'Expected exactly 2 generated PDFs, found %s\n' "$pdf_count" >&2
  exit 1
fi
