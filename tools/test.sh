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
  set -- "$ROOT"/tests/unit/*.pb
fi

rm -f "$report_file"

pureunit_report_success() {
  [ -f "$report_file" ] || return 1
  grep -q 'All tests completed' "$report_file" || return 1
  grep -A 1 'Failures:' "$report_file" | grep -q '>0<'
}

"$PUREUNIT" --compiler "$PB_COMPILER" --verbose --report "$report_file" "$@" &
pureunit_pid=$!
completed_seen=0
cleaned_up_standby=0

while kill -0 "$pureunit_pid" 2>/dev/null; do
  if pureunit_report_success; then
    completed_seen=$((completed_seen + 1))
    if [ "$completed_seen" -ge 5 ]; then
      cleaned_up_standby=1
      pkill -TERM -P "$pureunit_pid" 2>/dev/null || true
      kill -TERM "$pureunit_pid" 2>/dev/null || true
      sleep 1
      pkill -KILL -P "$pureunit_pid" 2>/dev/null || true
      kill -KILL "$pureunit_pid" 2>/dev/null || true
      wait "$pureunit_pid" 2>/dev/null || true
      break
    fi
  else
    completed_seen=0
  fi
  sleep 1
done

if [ "$cleaned_up_standby" -eq 1 ]; then
  printf 'PureUnit completed successfully; cleaned up a stalled standby compiler process.\n'
elif ! wait "$pureunit_pid"; then
  exit 1
fi

printf 'PureUnit report: %s\n' "$report_file"
