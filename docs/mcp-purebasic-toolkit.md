# MCP PureBasic Toolkit

`MCP/mcp-purebasic-toolkit` is the real PureBasic development companion project
that grows out of this library. It is not an example. It packages a stdio MCP
server, project-specific development tools, and Codex skills for PureBasic
development workflows.

Start here:

- `MCP/mcp-purebasic-toolkit/README.md`
- `MCP/mcp-purebasic-toolkit/docs/architecture.md`
- `MCP/mcp-purebasic-toolkit/docs/workflow.md`
- `MCP/mcp-purebasic-toolkit/docs/milestones.md`

Current foundation tools:

- `purebasic/project/inspect`
- `purebasic/workflow/brief`
- `purebasic/harness/checklist`
- `purebasic/include/graph`
- `purebasic/symbol/search`
- `purebasic/procedure/list`
- `purebasic/pbp/list-targets`
- `purebasic/test/run`
- `purebasic/build/run`
- `purebasic/check`
- `purebasic/docs/build`
- `purebasic/brief/create`
- `purebasic/algorithm/explain`
- `purebasic/decision-record/create`

Harness execution tools run fixed repository scripts only. They support
`dryRun`, bounded output, timeout controls, and project-root path sanitization.
Pair-development record tools return Markdown and save only when `save: true`
is requested, using `.local/mcp-purebasic-toolkit/records/`.

Toolkit milestones are intentionally tracked in
`MCP/mcp-purebasic-toolkit/docs/milestones.md` instead of the core library
milestone file.
