# PureBasic JSON-RPC 2.0

PureBasic JSON-RPC 2.0 is a planned library for stream-framed, testable JSON-RPC communication in PureBasic 6.40.

The implementation is guided by:

- `GUIDELINE.md`
- `PROJECT REQUEST.md`
- the official JSON-RPC 2.0 specification
- the architecture of Microsoft's `vscode-jsonrpc`
- the PureBasic 6.40 compiler and SDK PureUnit runner

## Target Implementation

The primary target for this library is future MCP server development in the PureBasic programming language.

The implementation should stay general-purpose enough for other JSON-RPC 2.0 use cases, but MCP server development is the main product context that should guide API shape, examples, tests, and documentation.

## Current Milestone

The current alpha target is `0.1.0-alpha.1`, with generic JSON-RPC foundation work completed through round `026-alpha-release-package`.

## Quick Start

```sh
./tools/discover-purebasic.sh
./tools/test.sh
./tools/build.sh
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

## Repository Layout

- `AGENTS.md` - required guidance for AI agents and contributors.
- `LICENSE` - MIT license for the source package.
- `API/` - public API documentation in Markdown.
- `docs/` - Read the Docs/Sphinx entrypoint.
- `examples/` - sequential scenario applications, one folder per milestone.
- `MCP/` - MCP-focused example projects without numeric prefixes.
- `src/jsonrpc/` - future library source.
- `tests/unit/` - PureUnit tests close to the library workflow.
- `tools/` - local discovery, build, test, and verification scripts.

## Required Toolchain

- PureBasic `6.40`
- PureUnit from the PureBasic SDK
- macOS ARM64 is verified by this first milestone; x64 compatibility remains a required design target for later milestones.
- The alpha source package defaults to the current host platform label, verified locally as macOS ARM64.
