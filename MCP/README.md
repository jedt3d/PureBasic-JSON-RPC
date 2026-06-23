# MCP Examples

This folder contains MCP-focused example projects that use the PureBasic JSON-RPC library.

Example project folders under `MCP/examples/` intentionally do not use numeric prefixes. The numbered `examples/` folder remains reserved for core library milestones and probes.

Each MCP example project must include a `.pbp` file in its folder. MCP stdio servers should use an explicit Console target so stdin/stdout are suitable for protocol transport and diagnostics can stay off stdout.

Current examples:

- `examples/purebasic-check/`: a stdio MCP server exposing `purebasic/check`,
  backed by the repository verification workflow.
- `examples/sqlite-admin/`: a macOS stdio MCP server for approved SQLite file
  administration, saved SQL recipes, backups, maintenance, and UTF-8 data
  round-trip checks. Start with `examples/sqlite-admin/TUTORIAL.md`.
