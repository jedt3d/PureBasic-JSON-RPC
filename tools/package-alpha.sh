#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. "$ROOT/tools/pb-env.sh"

pb_prepare_dirs

version="$(awk -F '"' '/JSONRPC_Library_Version/ { print $2; exit }' "$ROOT/src/jsonrpc/version.pbi")"
status="$(awk -F '"' '/JSONRPC_Library_Status/ { print $2; exit }' "$ROOT/src/jsonrpc/version.pbi")"

[ -n "$version" ] || pb_fail "Unable to read library version from src/jsonrpc/version.pbi"
[ "$status" = "alpha" ] || pb_fail "Alpha packaging requires library status alpha; detected: $status"

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
package_root="$ROOT/.build/package"
dist_root="$ROOT/.build/dist"
stage="$package_root/$package_name"
tarball="$dist_root/$package_name.tar.gz"
checksum="$tarball.sha256"
manifest="$dist_root/$package_name.manifest.txt"

copy_required_path() {
  rel="$1"
  [ -e "$ROOT/$rel" ] || pb_fail "Package source path missing: $rel"
  cp -R "$ROOT/$rel" "$stage/$rel"
}

rm -rf "$stage"
mkdir -p "$stage" "$dist_root"

copy_required_path "README.md"
copy_required_path "LICENSE"
copy_required_path "GUIDELINE.md"
copy_required_path "AGENTS.md"
copy_required_path "MILESTONES.md"
copy_required_path "PROJECT REQUEST.md"
copy_required_path "RELEASE_NOTES.md"
copy_required_path "API"
copy_required_path "docs"
copy_required_path "examples"
copy_required_path "src"
copy_required_path "tests"
copy_required_path "tools"

{
  printf 'Package: %s\n' "$package_name"
  printf 'Version: %s\n' "$version"
  printf 'Status: %s\n' "$status"
  printf 'Platform: %s\n' "$platform"
  printf 'Generated-By: tools/package-alpha.sh\n'
  printf '\nFiles:\n'
  find "$stage" -type f | sed "s|$stage/||" | LC_ALL=C sort
} > "$stage/PACKAGE_MANIFEST.txt"

rm -f "$tarball" "$checksum" "$manifest"
(cd "$package_root" && tar -czf "$tarball" "$package_name")
find "$stage" -type f | sed "s|$stage/||" | LC_ALL=C sort > "$manifest"
(cd "$dist_root" && shasum -a 256 "$(basename "$tarball")" > "$(basename "$checksum")")

printf 'Alpha package: %s\n' "$tarball"
printf 'Checksum: %s\n' "$checksum"
printf 'Manifest: %s\n' "$manifest"
