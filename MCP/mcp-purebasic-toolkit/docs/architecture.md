# MCP PureBasic Toolkit Architecture

This project turns the PureBasic JSON-RPC library into a development companion
package for PureBasic work. It is designed as a real MCP server plus a small set
of Codex skills.

## Product Idea

The toolkit should act as a pair developer for PureBasic projects:

1. Interview the human until requirements are clear.
2. Explain algorithm and control flow before implementation.
3. Ask for human decisions at semantic or policy boundaries.
4. Use MCP tools to inspect, build, test, document, and package.
5. Use skills to keep the agent's workflow disciplined.
6. Use Git and GitHub best practices for local and collaborative work.
7. Keep ReadTheDocs/Sphinx documentation current.
8. Treat lessons learned as defaults, not afterthoughts.

## Layers

```text
Codex skills
  pair development
  implementation cycle
  code review
  release manager
  MCP authoring
        |
MCP toolkit server
  purebasic/project/inspect
  purebasic/workflow/brief
  purebasic/harness/checklist
  purebasic/test/run, purebasic/build/run
  purebasic/check, purebasic/docs/build
  purebasic/brief/create
  purebasic/algorithm/explain
  purebasic/decision-record/create
        |
PureBasic JSON-RPC library
  MCP lifecycle/tools adapter
  stdio runtime and codec
  dispatch/protocol/connection
```

## Current Implementation

The first two slices are read-only and low risk: foundation context and project
intelligence. The harness-execution slice adds fixed-script process launch for
the repository's verification workflow, but still avoids arbitrary shell access
or Git mutation. The pair-development records slice turns interviews,
algorithm explanations, and technical decisions into Markdown outputs that can
optionally be saved under `.local/`.

Current implementation files:

- `purebasic_toolkit_server.pb`
- `purebasic_toolkit_tools.pbi`
- `purebasic_toolkit_probe.pb`
- `purebasic_toolkit.pbp`
- `probe_smoke_input.ndjson`

Current tool groups:

- Foundation context: `purebasic/project/inspect`, `purebasic/workflow/brief`,
  and `purebasic/harness/checklist`.
- Project intelligence: `purebasic/include/graph`,
  `purebasic/symbol/search`, `purebasic/procedure/list`, and
  `purebasic/pbp/list-targets`.
- Harness execution: `purebasic/test/run`, `purebasic/build/run`,
  `purebasic/check`, and `purebasic/docs/build`.
- Pair-development records: `purebasic/brief/create`,
  `purebasic/algorithm/explain`, and `purebasic/decision-record/create`.

Harness execution is deliberately not a general shell. Each tool maps to one
fixed repository script, captures combined stdout/stderr, replaces the
configured project root in output with `.`, and returns an MCP text result with
exit status, timeout status, and truncation status. `dryRun` is supported so a
pair-development session can review what would happen before launching a longer
command.

Record tools are conversational structure tools. They produce Markdown through
MCP text results and save only when `save: true` is requested. Saved records go
to `.local/mcp-purebasic-toolkit/records/` with simple file-name validation so
generated notes do not become tracked source or escape the project.

## Design Rules

- Keep the toolkit as a real project under `MCP/mcp-purebasic-toolkit`.
- Do not place toolkit milestones in the core library milestone file.
- Keep stdout protocol-only for stdio MCP servers.
- Keep diagnostics and logs off stdout.
- Use `.pbp` as the source of truth for PureBasic target type.
- Keep tracked paths relative to the repository root.
- Do not expose arbitrary shell execution through MCP tools.
- Bound command runtime and output whenever a tool launches a process.
- Keep generated pair-development records under `.local/` unless a human
  deliberately promotes them into tracked documentation.
- Run harness checks before claiming a route is complete.
- Update documentation and ReadTheDocs navigation when user-facing guidance
  changes.

## Future Tool Groups

- Project intelligence: deepen include graph, symbols, procedures, public API,
  and `.pbp` target analysis.
- Harness execution: add richer target selection and package/release
  verification after the initial fixed-script tools.
- Pair workflow: add richer question generation, record templates, and optional
  promotion paths from `.local/` into reviewed docs.
- Git/GitHub workflow: preflight, branch naming, commit summaries, PR drafts,
  CI inspection, and release notes.
- Docs workflow: API page skeletons, milestone updates, ReadTheDocs navigation,
  and release checklist verification.
- MCP authoring: new stdio server skeletons, tool registration, probe inputs,
  safety notes, and tests.
