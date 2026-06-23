#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_file() {
  path="$1"
  [ -s "$path" ] || fail "Missing or empty release artifact: $path"
}

require_manifest_entry() {
  entry="$1"
  if ! grep -F "$entry" "$manifest" >/dev/null; then
    fail "Missing manifest entry: $entry"
  fi
}

require_tar_entry() {
  entry="$1"
  if ! tar -tzf "$tarball" | grep -F "$entry" >/dev/null; then
    fail "Missing package tar entry: $entry"
  fi
}

version="$(awk -F '"' '/JSONRPC_Library_Version/ { print $2; exit }' "$ROOT/src/jsonrpc/version.pbi")"
status="$(awk -F '"' '/JSONRPC_Library_Status/ { print $2; exit }' "$ROOT/src/jsonrpc/version.pbi")"

[ -n "$version" ] || fail "Unable to read library version from src/jsonrpc/version.pbi"
[ "$status" = "alpha" ] || fail "Release artifact verifier currently expects alpha status; detected: $status"

os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"
case "$os_name" in
  darwin) os_name="macos" ;;
esac

machine="$(uname -m)"
case "$machine" in
  arm64|aarch64) arch_name="arm64" ;;
  x86_64|amd64) arch_name="x64" ;;
  *) arch_name="$machine" ;;
esac

platform="${PB_PACKAGE_PLATFORM:-$os_name-$arch_name}"
package_name="PureBasic-JSON-RPC-$version-$platform"
dist_root="$ROOT/.build/dist"
tarball="$dist_root/$package_name.tar.gz"
checksum="$tarball.sha256"
manifest="$dist_root/$package_name.manifest.txt"
overview_pdf="$dist_root/$package_name-mcp-for-purebasic.pdf"
tutorial_pdf="$dist_root/$package_name-tutorial.pdf"
overview_pdf_checksum="$overview_pdf.sha256"
tutorial_pdf_checksum="$tutorial_pdf.sha256"

require_file "$tarball"
require_file "$checksum"
require_file "$manifest"
require_file "$overview_pdf"
require_file "$overview_pdf_checksum"
require_file "$tutorial_pdf"
require_file "$tutorial_pdf_checksum"

(cd "$dist_root" && shasum -a 256 -c "$(basename "$checksum")" >/dev/null)
(cd "$dist_root" && shasum -a 256 -c "$(basename "$overview_pdf_checksum")" >/dev/null)
(cd "$dist_root" && shasum -a 256 -c "$(basename "$tutorial_pdf_checksum")" >/dev/null)

require_manifest_entry "Package: $package_name"
require_manifest_entry "Generated-By: tools/package-alpha.sh"
require_manifest_entry "docs/release-quality-gates.md"
require_manifest_entry "docs/jsonrpc-compliance-matrix.md"
require_manifest_entry "docs/security-robustness.md"
require_manifest_entry "docs/release-checklist.md"
require_manifest_entry "docs/milestones.md"
require_manifest_entry "docs/release-notes.md"
require_manifest_entry "API/027-release-quality-gates.md"
require_manifest_entry "API/028-compliance-matrix.md"
require_manifest_entry "API/029-negative-tests.md"
require_manifest_entry "API/030-stress-lifecycle.md"
require_manifest_entry "API/031-security-robustness.md"
require_manifest_entry "API/032-release-automation-polish.md"
require_manifest_entry "examples/032-release-automation-polish/README.md"
require_manifest_entry "examples/032-release-automation-polish/release_automation_probe.pb"
require_manifest_entry "examples/032-release-automation-polish/release_automation_polish.pbp"
require_manifest_entry "tests/unit/032_release_automation_polish.pb"
require_manifest_entry "tools/verify-docs.sh"
require_manifest_entry "tools/verify-paths.sh"
require_manifest_entry "tools/verify-release-artifacts.sh"
require_manifest_entry "$(basename "$tarball")"
require_manifest_entry "$(basename "$checksum")"
require_manifest_entry "$(basename "$overview_pdf")"
require_manifest_entry "$(basename "$overview_pdf_checksum")"
require_manifest_entry "$(basename "$tutorial_pdf")"
require_manifest_entry "$(basename "$tutorial_pdf_checksum")"

require_tar_entry "$package_name/docs/release-checklist.md"
require_tar_entry "$package_name/API/032-release-automation-polish.md"
require_tar_entry "$package_name/examples/032-release-automation-polish/release_automation_probe.pb"
require_tar_entry "$package_name/tests/unit/032_release_automation_polish.pb"
require_tar_entry "$package_name/tools/verify-release-artifacts.sh"

printf 'Verified release artifacts for %s.\n' "$package_name"
