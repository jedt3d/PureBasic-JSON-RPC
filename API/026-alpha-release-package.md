# 026 Alpha Release Package

Milestone `026-alpha-release-package` adds a repeatable source package step for the first alpha release.

## Package Script

```sh
./tools/package-alpha.sh
```

The script reads library metadata from `src/jsonrpc/version.pbi`, stages source files under `.build/package/`, and writes release artifacts under `.build/dist/`.

## Generated Artifacts

For the local macOS ARM64 target, the default output is:

```text
.build/dist/PureBasic-JSON-RPC-0.1.0-alpha.1-macos-arm64.tar.gz
.build/dist/PureBasic-JSON-RPC-0.1.0-alpha.1-macos-arm64.tar.gz.sha256
.build/dist/PureBasic-JSON-RPC-0.1.0-alpha.1-macos-arm64.manifest.txt
```

The platform suffix follows the current host by default. Set `PB_PACKAGE_PLATFORM` to override it for a deliberate package label.

## Included Source

The package contains:

- `README.md`, `LICENSE`, `GUIDELINE.md`, `AGENTS.md`, `MILESTONES.md`, `PROJECT REQUEST.md`, and `RELEASE_NOTES.md`
- `API/` and `docs/`
- `src/`, `tests/`, `examples/`, `MCP/`, and `tools/`
- generated `PACKAGE_MANIFEST.txt` inside the package root

Generated build directories such as `.build/`, `.local/`, and `.reports/` are not included.

## Verification

`tools/check.sh` now verifies PureBasic `.pbp` project metadata, runs the alpha release probe, and runs the package script after PureUnit tests and scenario builds.
