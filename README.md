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

The first milestone is `000-project-foundation`. It establishes the AI/contributor harness, PureBasic discovery, PureUnit execution, example application convention, documentation layout, and quality gates before protocol implementation begins.

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

## Repository Layout

- `AGENTS.md` - required guidance for AI agents and contributors.
- `API/` - public API documentation in Markdown.
- `docs/` - Read the Docs/Sphinx entrypoint.
- `examples/` - sequential scenario applications, one folder per milestone.
- `src/jsonrpc/` - future library source.
- `tests/unit/` - PureUnit tests close to the library workflow.
- `tools/` - local discovery, build, test, and verification scripts.

## Required Toolchain

- PureBasic `6.40`
- PureUnit from the PureBasic SDK
- macOS ARM64 is verified by this first milestone; x64 compatibility remains a required design target for later milestones.
