#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

slash="/"
absolute_home="${slash}Users${slash}"
absolute_purebasic="${slash}Applications${slash}PureBasic"
placeholder_absolute="${slash}absolute${slash}path"
pattern="$absolute_home|$absolute_purebasic|$placeholder_absolute"

cd "$ROOT"

if git grep -n -I -E "$pattern" -- > "$tmp"; then
  printf 'Tracked files contain workstation-specific absolute paths:\n' >&2
  cat "$tmp" >&2
  exit 1
fi

printf 'Verified tracked files do not contain workstation-specific absolute paths.\n'
