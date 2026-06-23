#!/usr/bin/env sh

PB_PROJECT_ROOT="${PB_PROJECT_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"

pb_detect_install_home() {
  if command -v pbcompiler >/dev/null 2>&1; then
    detected_compiler="$(command -v pbcompiler)"
    CDPATH= cd -- "$(dirname -- "$detected_compiler")/.." && pwd
    return 0
  fi

  if command -v mdfind >/dev/null 2>&1; then
    detected_app="$(mdfind 'kMDItemFSName == "PureBasic.app"' | sed -n '1p')"
    if [ -n "$detected_app" ] && [ -d "$detected_app/Contents/Resources" ]; then
      printf '%s\n' "$detected_app/Contents/Resources"
      return 0
    fi
  fi
}

PB_INSTALL_HOME="${PB_INSTALL_HOME:-$(pb_detect_install_home)}"
PB_LOCAL_HOME="${PB_LOCAL_HOME:-$PB_PROJECT_ROOT/.local/purebasic-home}"
PUREUNIT_LOCAL_HOME="${PUREUNIT_LOCAL_HOME:-$PB_PROJECT_ROOT/.local/pureunit-home}"

PB_HOME="${PB_HOME:-$PB_LOCAL_HOME}"
PUREBASIC_HOME="${PUREBASIC_HOME:-$PB_HOME}"
PB_COMPILER="${PB_COMPILER:-$PB_HOME/compilers/pbcompiler}"
PUREUNIT_HOME="${PUREUNIT_HOME:-$PUREUNIT_LOCAL_HOME}"
PUREUNIT="${PUREUNIT:-$PUREUNIT_HOME/pureunit}"

export PB_PROJECT_ROOT
export PB_INSTALL_HOME
export PB_LOCAL_HOME
export PUREUNIT_LOCAL_HOME
export PB_HOME
export PUREBASIC_HOME
export PB_COMPILER
export PUREUNIT_HOME
export PUREUNIT

pb_fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

pb_prepare_dirs() {
  mkdir -p "$PB_PROJECT_ROOT/.build" "$PB_PROJECT_ROOT/.reports" "$PB_PROJECT_ROOT/.local"
}

pb_link_children() {
  src_dir="$1"
  dst_dir="$2"

  mkdir -p "$dst_dir"
  find "$src_dir" -mindepth 1 -maxdepth 1 -exec ln -s {} "$dst_dir/" \;
}

pb_create_local_homes() {
  pb_prepare_dirs

  [ -n "$PB_INSTALL_HOME" ] || pb_fail "PureBasic installation home not discovered. Set PB_INSTALL_HOME or put pbcompiler on PATH."
  [ -d "$PB_INSTALL_HOME" ] || pb_fail "PureBasic installation home not found: $PB_INSTALL_HOME"
  [ -x "$PB_INSTALL_HOME/compilers/pbcompiler" ] || pb_fail "PureBasic compiler not found: $PB_INSTALL_HOME/compilers/pbcompiler"
  [ -d "$PB_INSTALL_HOME/sdk/pureunit" ] || pb_fail "PureUnit SDK not found: $PB_INSTALL_HOME/sdk/pureunit"
  [ -x "$PB_INSTALL_HOME/sdk/pureunit/pureunit" ] || pb_fail "PureUnit runner not found: $PB_INSTALL_HOME/sdk/pureunit/pureunit"

  rm -rf "$PB_LOCAL_HOME" "$PUREUNIT_LOCAL_HOME"
  mkdir -p "$PB_LOCAL_HOME/compilers" "$PB_LOCAL_HOME/residents" "$PUREUNIT_LOCAL_HOME"

  pb_link_children "$PB_INSTALL_HOME/compilers" "$PB_LOCAL_HOME/compilers"
  pb_link_children "$PB_INSTALL_HOME/residents" "$PB_LOCAL_HOME/residents"
  ln -s "$PB_INSTALL_HOME/purelibraries" "$PB_LOCAL_HOME/purelibraries"
  ln -s "$PB_INSTALL_HOME/subsystems" "$PB_LOCAL_HOME/subsystems"
  ln -s "$PB_INSTALL_HOME/sdk" "$PB_LOCAL_HOME/sdk"

  cp "$PB_INSTALL_HOME/sdk/pureunit/pureunit.res" "$PB_LOCAL_HOME/residents/pureunit.res"
  pb_link_children "$PB_INSTALL_HOME/sdk/pureunit" "$PUREUNIT_LOCAL_HOME"
}

pb_compiler_version() {
  "$PB_COMPILER" --version 2>&1 || true
}

pb_pureunit_version() {
  "$PUREUNIT" --version 2>&1 || true
}

pb_require_tools() {
  [ -n "$PB_INSTALL_HOME" ] || pb_fail "PureBasic installation home not discovered. Set PB_INSTALL_HOME or put pbcompiler on PATH."
  [ -d "$PB_INSTALL_HOME" ] || pb_fail "PureBasic installation home not found: $PB_INSTALL_HOME"
  [ -d "$PB_HOME" ] || pb_fail "PureBasic home not found: $PB_HOME"
  [ -x "$PB_COMPILER" ] || pb_fail "PureBasic compiler not executable: $PB_COMPILER"
  [ -d "$PUREUNIT_HOME" ] || pb_fail "PureUnit home not found: $PUREUNIT_HOME"
  [ -x "$PUREUNIT" ] || pb_fail "PureUnit runner not executable: $PUREUNIT"

  version_text="$(pb_compiler_version)"
  case "$version_text" in
    *"PureBasic 6.40"*) ;;
    *) pb_fail "PureBasic 6.40 is required; detected: $version_text" ;;
  esac
}

pb_print_summary() {
  printf 'Project root: %s\n' "$PB_PROJECT_ROOT"
  printf 'PureBasic install home: %s\n' "$PB_INSTALL_HOME"
  printf 'PureBasic home: %s\n' "$PB_HOME"
  printf 'PureBasic compiler: %s\n' "$PB_COMPILER"
  printf 'PureUnit home: %s\n' "$PUREUNIT_HOME"
  printf 'PureUnit runner: %s\n' "$PUREUNIT"
  printf 'Compiler version: %s\n' "$(pb_compiler_version | sed -n '1p')"
  printf 'PureUnit version: %s\n' "$(pb_pureunit_version | sed -n '1p')"
}
