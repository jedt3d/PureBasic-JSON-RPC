# PureBasic JSON-RPC 2.0

PureBasic JSON-RPC 2.0 is an alpha-stage library for stream-framed, testable JSON-RPC communication in PureBasic 6.40.

The implementation is guided by:

- `docs/guideline.md`
- `docs/project-request.md`
- the official JSON-RPC 2.0 specification
- the architecture of Microsoft's `vscode-jsonrpc`
- the PureBasic 6.40 compiler and SDK PureUnit runner

## Target Implementation

The primary target for this library is MCP server development in the PureBasic programming language.

The implementation should stay general-purpose enough for other JSON-RPC 2.0 use cases, but MCP server development is the main product context that should guide API shape, examples, tests, and documentation.

## Current Milestone

The current alpha target is `0.1.0-alpha.1`, with generic JSON-RPC foundation work completed through round `026-alpha-release-package`.

## Quick Start

All project-local paths in this repository are written relative to the repository
root. Generated work belongs under `.local/`, `.build/`, and `.reports/`; do not
commit machine-specific absolute paths into docs, source, project metadata, or
example configuration.

```sh
./tools/discover-purebasic.sh
./tools/verify-projects.sh
./tools/test.sh
./tools/build.sh
./tools/build-docs.sh
./.build/examples/000-project-foundation/console_probe
```

Or run the full local check:

```sh
./tools/check.sh
```

Create the local alpha source package:

```sh
./tools/package-alpha.sh
```

The package step also generates the long-form documentation PDFs in `.build/dist/`.

## Repository Layout

- `AGENTS.md` - required guidance for AI agents and contributors.
- `LICENSE` - MIT license for the source package.
- `API/` - public API documentation in Markdown.
- `docs/` - Read the Docs/Sphinx entrypoint, project request, guideline, milestones, and release notes.
- `examples/` - sequential scenario applications, one folder per milestone.
- `MCP/` - MCP-focused example projects without numeric prefixes.
- `src/jsonrpc/` - library source.
- `tests/unit/` - PureUnit tests close to the library workflow.
- `tools/` - local discovery, build, test, and verification scripts.

## Documentation

The API pages are reference documentation. The narrative path starts with `docs/mcp-for-purebasic.md` for the MCP and PureBasic overview, then `docs/tutorial-building-with-purebasic-jsonrpc.md` for the end-to-end tutorial. `./tools/build-docs.sh` builds Sphinx HTML and exactly two generated PDFs under `.build/docs-pdf/`.

## PureBasic Project Files

The root project file is `PureBasic-JSON-RPC.pbp`. Every buildable scenario or MCP example also has a committed `.pbp` project file. These files are the source of truth for target type: console application, GUI executable/application, or shared library. The harness verifies them with `./tools/verify-projects.sh` and builds them through `PureBasic --build`.

## Required Toolchain

- PureBasic `6.40`
- PureUnit from the PureBasic SDK
- macOS ARM64 is the verified local target; macOS x64 remains a build-as-is and design target.
- The alpha source package defaults to the current host platform label, verified locally as macOS ARM64.
