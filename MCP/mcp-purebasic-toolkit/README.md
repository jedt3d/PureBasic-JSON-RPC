# MCP PureBasic Toolkit

`MCP/mcp-purebasic-toolkit` is a real MCP project for PureBasic development,
not an example folder. It packages a stdio MCP server together with Codex skills
and project guidance for building, reviewing, testing, documenting, and
releasing PureBasic projects.

The first foundation slice is intentionally read-only. It gives an MCP host a
project inspection tool, a pair-development workflow brief, and a harness/Git
checklist. Later milestones will add build/test execution, `.pbp` project
management, docs automation, milestone generation, and MCP authoring helpers.

## Current Tools

- `purebasic/project/inspect` - inspect the current project structure, harness,
  docs, tests, examples, and toolkit state.
- `purebasic/workflow/brief` - return the default pair-development workflow:
  interview, explain algorithm/flow, ask for human decisions, implement, verify,
  document, and use Git/GitHub intentionally.
- `purebasic/harness/checklist` - return the local harness, ReadTheDocs,
  release artifact, Git, and GitHub checklist.
- `purebasic/include/graph` - list `IncludeFile` and `XIncludeFile` edges from
  JSON-RPC and toolkit source.
- `purebasic/symbol/search` - search source, docs, project files, and harness
  scripts with repository-relative results.
- `purebasic/procedure/list` - list PureBasic procedure, declare, prototype,
  and structure lines with an optional prefix filter.
- `purebasic/pbp/list-targets` - list committed `.pbp` targets and target
  formats using repository-relative paths.

## Build

The project is controlled by `purebasic_toolkit.pbp`. Both targets are explicit
Console targets.

```sh
./tools/verify-projects.sh
./tools/build.sh
```

Generated binaries are written under:

```text
.build/MCP/mcp-purebasic-toolkit/
```

## Smoke Probe

Run the compiled dispatcher probe:

```sh
./.build/MCP/mcp-purebasic-toolkit/purebasic_toolkit_probe
```

Run the stdio server with probe input:

```sh
./.build/MCP/mcp-purebasic-toolkit/purebasic_toolkit_server < MCP/mcp-purebasic-toolkit/probe_smoke_input.ndjson
```

The full repository check runs both paths.

## Project Intelligence Scope

The first intelligence tools are intentionally read-only and bounded. They are
not a replacement for compiler or static-analysis tooling. They provide fast
project orientation for a pair-development session: where includes point, which
symbols exist, which procedures are likely public, and which `.pbp` targets
define buildable PureBasic programs.

## Skills

Bundled skills live under `skills/`:

- `purebasic-pair-development`
- `purebasic-implementation-cycle`
- `purebasic-code-review`
- `purebasic-release-manager`
- `purebasic-mcp-authoring`

They are packaged with this project first. They are not installed globally by
default.

## Milestones

Toolkit milestones are tracked separately in:

```text
MCP/mcp-purebasic-toolkit/docs/milestones.md
```

Do not mix toolkit milestones into the core library milestone file unless the
core JSON-RPC library itself changes.
