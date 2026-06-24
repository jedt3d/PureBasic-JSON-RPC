# MCP PureBasic Toolkit Milestones

This file tracks milestones for `MCP/mcp-purebasic-toolkit`. It is deliberately
separate from `docs/milestones.md`, which tracks the core JSON-RPC library.

The toolkit is a real MCP development companion project, not a numbered example
under `examples/` and not an MCP example under `MCP/examples/`.

## 000-toolkit-foundation

Branch: `feature/mcp-purebasic-toolkit-foundation`

Status: completed

Purpose:

- Create the real toolkit project under `MCP/mcp-purebasic-toolkit`.
- Add a stdio MCP server with explicit Console `.pbp` targets.
- Add safe read-only foundation tools.
- Add bundled Codex skill drafts for PureBasic development workflows.
- Track toolkit milestones separately from the core library.
- Link the toolkit into repository documentation and harness verification.

Tools:

- `purebasic/project/inspect`
- `purebasic/workflow/brief`
- `purebasic/harness/checklist`

Acceptance criteria:

- `purebasic_toolkit.pbp` declares console targets for server and probe.
- `tools/verify-projects.sh` sees the toolkit targets.
- `tools/build.sh` builds the toolkit server and probe.
- `tools/check.sh` runs the toolkit probe and stdio smoke input.
- Skill folders validate with `quick_validate.py`.
- Toolkit docs explain pair development, algorithm review, human decisions,
  Git/GitHub workflow, ReadTheDocs, harness defaults, and lessons learned.

## 001-project-intelligence

Branch: `feature/mcp-toolkit-project-intelligence`

Status: completed

Purpose:

- Expand `purebasic/project/inspect` into richer project intelligence.
- Add include graph and symbol lookup tools.
- Summarize `.pb`, `.pbi`, `.pbp`, tests, docs, and public API surfaces.

Candidate tools:

- `purebasic/include/graph`
- `purebasic/symbol/search`
- `purebasic/procedure/list`
- `purebasic/pbp/list-targets`

Acceptance criteria:

- Include graph reports `IncludeFile` and `XIncludeFile` edges with
  repository-relative paths.
- Symbol search accepts a `query` argument and rejects missing query with
  `-32602`.
- Procedure list supports an optional `prefix` filter.
- `.pbp` target listing reports project file, target name, target format, input,
  and output with repository-relative paths.
- Toolkit probe covers all project-intelligence tools.
- PureUnit coverage exists in `tests/unit/mcp_purebasic_toolkit.pb`.
- `./tools/check.sh` passes.

## 002-harness-execution

Branch: `feature/mcp-toolkit-harness-execution`

Status: completed

Purpose:

- Add bounded execution tools for build, test, docs, and check workflows.
- Keep command execution explicit, bounded, and developer-facing.

Tools:

- `purebasic/test/run`
- `purebasic/build/run`
- `purebasic/check`
- `purebasic/docs/build`

Acceptance criteria:

- Execution tools map only to fixed repository harness scripts.
- Tools support `dryRun`, `timeoutMs`, and `maxOutputBytes`.
- Command output is bounded and reports truncation state.
- Captured output replaces the configured project root with `.`.
- Invalid timeout or output limit returns JSON-RPC `-32602`.
- Toolkit probe covers dry-run command dispatch without recursively launching
  `./tools/check.sh`.
- PureUnit coverage validates registration, invalid options, dry-run output,
  and the shared runner through a fast verifier command.
- `./tools/check.sh` passes.

## 003-pair-development-records

Status: planned

Purpose:

- Turn the interview and algorithm explanation workflow into reusable MCP
  outputs and persisted brief files when requested.

Candidate tools:

- `purebasic/brief/create`
- `purebasic/algorithm/explain`
- `purebasic/decision-record/create`

## 004-git-github-workflow

Status: planned

Purpose:

- Add Git/GitHub workflow helpers for local-only and local-plus-GitHub
  development.

Candidate tools:

- `purebasic/git/preflight`
- `purebasic/git/commit-summary`
- `purebasic/github/pr-draft`
- `purebasic/github/release-draft`

## 005-docs-and-milestone-automation

Status: planned

Purpose:

- Automate route documentation checks without replacing human technical review.
- Keep ReadTheDocs/Sphinx as a default part of every route.

Candidate tools:

- `purebasic/docs/check`
- `purebasic/docs/update-route`
- `purebasic/milestone/create`

## 006-mcp-authoring-kit

Status: planned

Purpose:

- Use the JSON-RPC library and toolkit skills to create new PureBasic MCP
  servers safely and consistently.

Candidate tools:

- `purebasic/mcp/new-server`
- `purebasic/mcp/add-tool`
- `purebasic/mcp/probe`
- `purebasic/mcp/validate-stdio`
