# MCP Projects

This folder contains MCP-focused projects that use the PureBasic JSON-RPC
library.

`MCP/mcp-purebasic-toolkit/` is a real development toolkit project, not an
example. Its milestones are tracked separately in
`MCP/mcp-purebasic-toolkit/docs/milestones.md`.

Example project folders under `MCP/examples/` intentionally do not use numeric prefixes. The numbered `examples/` folder remains reserved for core library milestones and probes.

Each MCP example project must include a `.pbp` file in its folder. MCP stdio servers should use an explicit Console target so stdin/stdout are suitable for protocol transport and diagnostics can stay off stdout.

Current examples:

- `examples/purebasic-check/`: a stdio MCP server exposing `purebasic/check`,
  backed by the repository verification workflow.
- `examples/sqlite-admin/`: a macOS stdio MCP server for approved SQLite file
  administration, saved SQL recipes, backups, maintenance, CSV/ODS/XLSX
  exports, and UTF-8 data round-trip checks. Start with
  `examples/sqlite-admin/TUTORIAL.md`.

Current real projects:

- `mcp-purebasic-toolkit/`: a stdio MCP server plus Codex skills for PureBasic
  pair development, project inspection, harness discipline, docs workflow,
  Git/GitHub workflow, release management, and future MCP authoring.
