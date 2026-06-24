#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"

pb_prepare_dirs
pb_create_local_homes
pb_require_tools

report_dir="$ROOT/.reports/pureunit"
summary_report_file="$report_dir/index.html"
timeout_seconds="${PUREUNIT_TIMEOUT_SECONDS:-60}"
retry_limit="${PUREUNIT_RETRY_LIMIT:-3}"
mkdir -p "$report_dir"

if [ "$#" -eq 0 ]; then
  set -- "$ROOT"/tests/unit/*.pb
fi

rm -f "$report_dir"/*.html

pureunit_report_success() {
  report_file="$1"
  [ -f "$report_file" ] || return 1
  grep -q 'All tests completed' "$report_file" || return 1
  grep -A 1 'Failures:' "$report_file" | grep -q '>0<'
}

pureunit_kill_tree() {
  pureunit_pid="$1"
  pkill -TERM -P "$pureunit_pid" 2>/dev/null || true
  kill -TERM "$pureunit_pid" 2>/dev/null || true
  sleep 1
  pkill -KILL -P "$pureunit_pid" 2>/dev/null || true
  kill -KILL "$pureunit_pid" 2>/dev/null || true
}

run_pureunit_report() {
  report_file="$1"
  shift

  attempt=1
  while [ "$attempt" -le "$retry_limit" ]; do
    rm -f "$report_file"

    "$PUREUNIT" --compiler "$PB_COMPILER" --verbose --report "$report_file" "$@" &
    pureunit_pid=$!
    completed_seen=0
    cleaned_up_standby=0
    elapsed=0
    timed_out=0

    while kill -0 "$pureunit_pid" 2>/dev/null; do
      if pureunit_report_success "$report_file"; then
        completed_seen=$((completed_seen + 1))
        if [ "$completed_seen" -ge 5 ]; then
          cleaned_up_standby=1
          pureunit_kill_tree "$pureunit_pid"
          wait "$pureunit_pid" 2>/dev/null || true
          break
        fi
      else
        completed_seen=0
      fi

      if [ "$elapsed" -ge "$timeout_seconds" ]; then
        printf 'PureUnit timed out after %s seconds before completion on attempt %s/%s: %s\n' "$timeout_seconds" "$attempt" "$retry_limit" "$*"
        pureunit_kill_tree "$pureunit_pid"
        wait "$pureunit_pid" 2>/dev/null || true
        timed_out=1
        break
      fi

      sleep 1
      elapsed=$((elapsed + 1))
    done

    if [ "$timed_out" -eq 1 ]; then
      attempt=$((attempt + 1))
      continue
    fi

    if [ "$cleaned_up_standby" -eq 1 ]; then
      printf 'PureUnit completed successfully; cleaned up a stalled standby compiler process.\n'
    elif ! wait "$pureunit_pid"; then
      return 1
    fi

    if pureunit_report_success "$report_file"; then
      printf 'PureUnit report: %s\n' "$report_file"
      return 0
    fi

    printf 'PureUnit did not produce a successful report on attempt %s/%s: %s\n' "$attempt" "$retry_limit" "$report_file"
    attempt=$((attempt + 1))
  done

  printf 'PureUnit failed after %s attempts: %s\n' "$retry_limit" "$*"
  return 1
}

write_summary_report() {
  summary_file="$1"
  total="$2"

  {
    printf '<!doctype html>\n'
    printf '<html><head><meta charset="utf-8"><title>PureUnit Summary</title></head><body>\n'
    printf '<h1>PureUnit Summary</h1>\n'
    printf '<p>All tests completed successfully across %s files.</p>\n' "$total"
    printf '<ul>\n'
    for report in "$report_dir"/*.html; do
      [ "$report" = "$summary_file" ] && continue
      [ -f "$report" ] || continue
      name="$(basename "$report")"
      printf '<li><a href="%s">%s</a></li>\n' "$name" "$name"
    done
    printf '</ul>\n'
    printf '</body></html>\n'
  } > "$summary_file"
}

if [ "$#" -eq 1 ]; then
  run_pureunit_report "$summary_report_file" "$1"
  exit $?
fi

total=0
for test_file in "$@"; do
  total=$((total + 1))
  report_name="$(basename "$test_file" .pb | tr -c 'A-Za-z0-9_.-' '_').html"
  printf 'Running PureUnit file %s: %s\n' "$total" "$test_file"
  run_pureunit_report "$report_dir/$report_name" "$test_file"
done

write_summary_report "$summary_report_file" "$total"
printf 'PureUnit summary report: %s\n' "$summary_report_file"
