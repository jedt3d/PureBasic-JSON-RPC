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
- `purebasic/git/preflight`
- `purebasic/git/commit-summary`
- `purebasic/github/pr-draft`
- `purebasic/github/release-draft`
- `purebasic/docs/check`
- `purebasic/docs/update-route`
- `purebasic/milestone/create`
- `purebasic/mcp/new-server`
- `purebasic/mcp/add-tool`
- `purebasic/mcp/probe`
- `purebasic/mcp/validate-stdio`

Harness execution tools run fixed repository scripts only. They support
`dryRun`, bounded output, timeout controls, and project-root path sanitization.
Pair-development record tools return Markdown and save only when `save: true`
is requested, using `.local/mcp-purebasic-toolkit/records/`.
Git/GitHub workflow tools inspect local Git state and draft commit, PR, or
release text without committing, pushing, tagging, or publishing.
Documentation and milestone automation tools audit route coverage and draft
updates without modifying tracked source-of-truth files automatically.
MCP authoring tools draft server scaffolds, individual tool handlers, probe
input, and stdio transcript validation reports. Drafts can be saved under
`.local/mcp-purebasic-toolkit/records/mcp-authoring/`, while tracked server
files remain human-reviewed implementation work.

Dogfood sample implementation work is tracked separately from MCP server
examples. `Gadgets/SevenSegmentClock/` is the first tracked sample target for
the toolkit plus skills workflow; it starts milestone `00.07` with a committed
PRD before source, `.pbp` targets, examples, tests, and asset licenses are added.

Toolkit milestones are intentionally tracked in
`MCP/mcp-purebasic-toolkit/docs/milestones.md` instead of the core library
milestone file.
