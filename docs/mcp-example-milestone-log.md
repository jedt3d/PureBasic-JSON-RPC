# MCP Example Milestone Log

This document records the unnumbered MCP example and release-support work that
continued after the core JSON-RPC milestone sequence. It is a companion to
`milestones.md`, which tracks the numbered foundation rounds from `000` through
`016`.

The source of truth for this log is the Git history. Commit hashes are included
so future maintainers can connect each milestone entry to the actual repository
changes.

## Why This Log Exists

The original milestone track focused on building a reusable JSON-RPC 2.0 and MCP
foundation in PureBasic. After the alpha package work, the project deliberately
shifted into real MCP examples:

- proving that PureBasic can compile stdio MCP servers as Console targets;
- using `.pbp` project files as the build contract;
- adding long-form documentation and generated PDF artifacts;
- building a real SQLite administration MCP server;
- adding CSV, ODS, and XLSX export capability to that server;
- tightening path and safety documentation after the examples became more
  practical.

Those changes are not a distraction from the main project. They are evidence for
the main product thesis: PureBasic can be used to build local, native MCP tool
servers on top of this JSON-RPC library.

## Commit-Derived Timeline

| Date | Commit | Milestone | Result |
| --- | --- | --- | --- |
| 2026-06-23 | `889e5b9` | Alpha package baseline | Tagged `v0.1.0-alpha.1` after alpha packaging and license inclusion. |
| 2026-06-23 | `4467bfb` | `purebasic/check` MCP example | Added the first real stdio MCP server example. |
| 2026-06-23 | `3efc157` | Console `.pbp` for MCP check | Made the MCP check server explicitly build as a Console target. |
| 2026-06-23 | `299ded6` | `.pbp` project build contract | Moved scenario and MCP builds to committed PureBasic project metadata. |
| 2026-06-23 | `f85efff` | Root project file | Added `PureBasic-JSON-RPC.pbp` so the main project follows the same build contract. |
| 2026-06-23 | `08a283c` | Long-form docs and PDFs | Added overview/tutorial Markdown plus PDF generation and packaging support. |
| 2026-06-23 | `26b1077` | SQLite admin MCP example | Added a real SQLite stdio MCP server with bootstrap, inspect, query, execute, backup, maintenance, recipes, probes, tests, and tutorial. |
| 2026-06-23 | `386c7cf` | CSV export | Added canonical UTF-8 CSV export with quoting, BOM, CRLF, row limits, probes, and tests. |
| 2026-06-23 | `1002d9b` | ODS export | Added OpenDocument Spreadsheet export with package structure and UTF-8 XML tests. |
| 2026-06-23 | `cec5bed` | Export tutorial expansion | Expanded the SQLite tutorial around multi-format exports. |
| 2026-06-23 | `5e823a3` | XLSX export | Added macro-free XLSX export with OOXML package generation and tests. |
| 2026-06-23 | `8646bba` | Project-relative path hygiene | Removed machine-specific path leakage from docs and tool responses. |
| 2026-06-23 | `6eea062` | Alpha cleanup notes | Refreshed alpha wording and documented SQLite admin safety expectations. |

## MCP Example Milestones

### MCP-A01: `purebasic/check`

Commits: `4467bfb`, `3efc157`

Purpose:

- Add the first MCP-focused example under `MCP/examples/`.
- Build a real stdio MCP server, not just a probe.
- Expose one tool, `purebasic/check`, backed by `./tools/check.sh`.
- Keep stdout protocol-only and reserve diagnostics for stderr.
- Compile the server through a `.pbp` Console target.

Acceptance evidence:

- `MCP/examples/purebasic-check/` contains server source, tool implementation,
  probe input, README, and a `.pbp` project file.
- `tests/unit/mcp_purebasic_check.pb` covers tool listing, tool calling, output
  bounding, command failure, and slash-containing tool names.
- `tools/check.sh` smoke-tests the server using stdio probe input.

### MCP-A02: Project Build Contract

Commits: `299ded6`, `f85efff`

Purpose:

- Make committed `.pbp` files the source of truth for target type, source file,
  output path, thread mode, and CPU target.
- Stop treating raw compiler flags as the primary way to define Console, app, or
  shared-library builds.
- Add a root project file for the JSON-RPC library verification target.

Acceptance evidence:

- `tools/pbp-projects.sh` lists all project targets.
- `tools/verify-projects.sh` verifies project metadata before builds.
- `tools/build.sh` builds targets through the PureBasic IDE command-line
  builder.
- `./tools/verify-projects.sh` currently verifies `35` targets.

### MCP-A03: Long-Form Documentation And PDF Artifacts

Commit: `08a283c`

Purpose:

- Explain MCP and PureBasic for readers who do not already know the protocol.
- Provide a book-style tutorial for the JSON-RPC/MCP library layers and examples.
- Generate Sphinx HTML plus two PDF release artifacts during documentation and
  alpha packaging flows.

Acceptance evidence:

- `docs/mcp-for-purebasic.md` introduces MCP, JSON-RPC, stdio, PureBasic, and
  the project purpose.
- `docs/tutorial-building-with-purebasic-jsonrpc.md` walks through the library
  stack and examples.
- `tools/build-docs.sh` builds Read the Docs HTML and exactly two PDFs.
- `tools/package-alpha.sh` copies the PDFs into `.build/dist/` and generates
  checksums.

### MCP-A04: SQLite Admin MCP Server

Commit: `26b1077`

Purpose:

- Add a realistic macOS stdio MCP server for administering approved SQLite files.
- Demonstrate bootstrap, schema inspection, bounded queries, intentional writes,
  backups, maintenance, saved SQL recipes, UTF-8 sample data, and exact
  multilingual round-trip behavior.
- Keep the server local and developer-facing rather than presenting it as a
  production sandbox.

Acceptance evidence:

- `MCP/examples/sqlite-admin/` contains server source, tool implementation,
  bootstrap program, scenario probe, `.pbp` project, probe input, README, script,
  and long tutorial.
- `tests/unit/mcp_sqlite_admin.pb` covers bootstrap, i18n round-trip, inspect,
  query limits, execute, recipes, invalid path rejection, backup, and
  maintenance.
- `tools/check.sh` runs both stdio probes and the compiled SQLite admin scenario.

### MCP-A05: SQLite Export Formats

Commits: `386c7cf`, `1002d9b`, `cec5bed`, `5e823a3`

Purpose:

- Add practical query result export capabilities to the SQLite admin MCP server.
- Start with canonical CSV, then add ODS, then add macro-free XLSX.
- Keep export output bounded and inside the approved SQLite admin root.
- Document the tradeoffs between CSV, ODS, and XLSX for PureBasic users.

Acceptance evidence:

- `sqlite/export` supports `csv`, `ods`, and `xlsx`.
- CSV export writes UTF-8 with BOM, CRLF row endings, and double quotes every
  field.
- ODS export writes a ZIP-based OpenDocument Spreadsheet package.
- XLSX export writes a macro-free OOXML workbook package using inline strings.
- Unit tests cover file creation, package structure, escaping, UTF-8 text, row
  limits, overwrite behavior, and extension validation.
- The SQLite tutorial includes hands-on export walkthroughs for all three
  formats.

### MCP-A06: Path Hygiene And Safety Notes

Commits: `8646bba`, `6eea062`

Purpose:

- Keep tracked docs, source constants, probe data, and example configuration
  project-root-relative.
- Stop leaking workstation-specific paths in MCP tool results when paths point
  back into the repository.
- Refresh README wording from planned work to alpha-stage implementation.
- Clarify that `sqlite/execute` is an administrator/developer tool and not a
  sandbox.

Acceptance evidence:

- SQLite tool results now report paths such as `.local/sqlite-admin/...`.
- Tests assert bootstrap and export responses do not expose the absolute test
  root.
- The tracked path scan for `/Users/`, `/Applications/PureBasic`, and
  `/absolute/path` returns no matches outside ignored build/local output.
- SQLite docs recommend reviewing SQL, backing up before write or DDL
  operations, and using host/user confirmation where available.

## Current Status

As of merge commit `0257cad`, the repository has:

- the core JSON-RPC foundation through alpha packaging;
- MCP lifecycle, tools registry, and tool-call helpers;
- a `purebasic/check` MCP server example;
- a SQLite admin MCP server example;
- CSV, ODS, and XLSX query export from the SQLite admin example;
- `.pbp` project files as the build contract;
- Read the Docs HTML and two generated PDF release artifacts;
- a full local check that runs PureUnit, builds, scenario probes, MCP stdio
  smoke tests, docs, and alpha packaging.

## Open Follow-Up Track

The next planning discussion should treat SQLite admin production hardening as a
separate milestone family. Candidate topics include read-only mode, explicit
write policy, stronger approval guidance, richer recipe parameter validation,
configurable allowed roots, and audit logging. Those controls were intentionally
not implemented in the quick alpha cleanup.
