# MCP PureBasic Toolkit

`MCP/mcp-purebasic-toolkit` is a real MCP project for PureBasic development,
not an example folder. It packages a stdio MCP server together with Codex skills
and project guidance for building, reviewing, testing, documenting, and
releasing PureBasic projects.

The foundation and project-intelligence slices are read-only. Harness execution
tools are now available for the repository's fixed verification scripts. They
do not accept arbitrary shell commands; each tool runs one whitelisted harness
script with timeout and output limits. Use `dryRun: true` when an MCP host
should explain the command before launching it. Pair-development record tools
produce Markdown and save only under `.local/` when explicitly requested.

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
- `purebasic/test/run` - run `./tools/test.sh` with bounded output and timeout
  controls.
- `purebasic/build/run` - run `./tools/build.sh` with bounded output and
  timeout controls.
- `purebasic/check` - run `./tools/check.sh` with bounded output and timeout
  controls.
- `purebasic/docs/build` - run `./tools/build-docs.sh` with bounded output and
  timeout controls.
- `purebasic/brief/create` - create a pair-development implementation brief as
  Markdown.
- `purebasic/algorithm/explain` - create an algorithm and control-flow
  explanation before implementation.
- `purebasic/decision-record/create` - create a concise technical decision
  record.

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

## Harness Execution Scope

Harness execution tools are intentionally narrow:

- allowed commands are fixed in source and point to repository scripts under
  `tools/`
- output is bounded and marked as truncated when the response limit is reached
- `timeoutMs` defaults to `300000` and is constrained between `1000` and
  `900000`
- `maxOutputBytes` defaults to `20000` and is constrained between `1000` and
  `60000`
- captured output replaces the configured project root with `.` so MCP results
  do not depend on a developer's workstation path

These tools are developer-facing execution helpers, not a sandbox. A host or
human reviewer should still decide when to run expensive commands such as
`purebasic/check`.

## Pair-Development Records

Record tools turn conversation into reviewable Markdown:

- implementation briefs clarify goal, non-goals, risks, tests, docs, and open
  questions
- algorithm explanations capture inputs, flow, state ownership, error behavior,
  and human decision points
- decision records capture context, decision, options, consequences, and
  follow-up

By default these tools return MCP text only. When `save: true` is supplied, the
record is written under `.local/mcp-purebasic-toolkit/records/`. File names must
be simple Markdown file names; path traversal such as `../` is rejected with
JSON-RPC `-32602`. Generated records stay outside tracked source until a human
promotes them.

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
