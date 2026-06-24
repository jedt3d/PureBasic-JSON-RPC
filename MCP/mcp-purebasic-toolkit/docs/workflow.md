# PureBasic Development Companion Workflow

This workflow captures the working agreement for the toolkit.

## Pair Development First

Before implementation, the agent should interview the human until the work is
clear enough to build. The interview should identify:

- goal and non-goals
- target area: core JSON-RPC, MCP adapter, real MCP project, docs, release, or
  skill
- target type: console, application, or shared library
- public API impact
- expected input and output shape
- important failure cases
- security or filesystem policy
- tests, examples, docs, and harness updates
- Git branch and merge path

The agent should summarize the brief before code changes unless the user has
already supplied a complete implementation plan.

Use `purebasic/brief/create` to turn that summary into a Markdown brief. Leave
`save` unset for transient MCP output, or use `save: true` to write the brief
under `.local/mcp-purebasic-toolkit/records/briefs/`.

Use the toolkit project-intelligence tools early in the interview when the code
base is unfamiliar:

- `purebasic/project/inspect`
- `purebasic/include/graph`
- `purebasic/symbol/search`
- `purebasic/procedure/list`
- `purebasic/pbp/list-targets`

## Algorithm And Human Decisions

Before touching risky code, explain:

- input validation
- control flow
- state changes
- JSON ownership and cleanup
- error behavior
- output format
- diagnostics and tracing
- docs and test impact

Ask the human to decide when semantics are product choices rather than mechanical
implementation details.

Use `purebasic/algorithm/explain` before implementation when the flow needs to
be reviewed, and `purebasic/decision-record/create` when a product or technical
choice should be preserved. Saved records are generated under `.local/` and
should be promoted into tracked documentation only after human review.

Examples:

- Should invalid MCP tool arguments return JSON-RPC `-32602` or an MCP tool
  result with `isError: true`?
- Should a filesystem path policy reject by default or allow explicit config?
- Should a new procedure be public API or internal helper?

## Git And GitHub

Local workflow:

```sh
git status --short --branch
git checkout -b feature/name
./tools/check.sh
git diff --check
git commit
git checkout main
git merge --no-ff feature/name
```

Local plus GitHub workflow:

```sh
git checkout main
git pull --ff-only
git checkout -b feature/name
./tools/check.sh
git push origin feature/name
```

Open a PR when review or CI is needed. Include verification evidence in the PR
summary.

Use the Git/GitHub MCP helpers before taking irreversible or collaborative
steps:

- `purebasic/git/preflight` inspects branch, status, diff stats, and recent
  commits.
- `purebasic/git/commit-summary` drafts a commit message and summary without
  staging or committing.
- `purebasic/github/pr-draft` drafts PR text without pushing or opening a PR.
- `purebasic/github/release-draft` drafts release notes and artifact checks
  without creating tags or releases.

These tools are intentionally read-only or draft-only. Real Git/GitHub actions
remain human-approved steps.

## Documentation

ReadTheDocs/Sphinx is part of the route, not a release-only task.

Default documentation updates:

- API page when public behavior changes
- route or toolkit milestone
- README or tutorial when user-facing behavior changes
- `docs/index.md` for major docs
- release notes for harness, packaging, behavior, or policy changes

Run:

```sh
./tools/verify-docs.sh
./tools/build-docs.sh
```

The MCP toolkit exposes `purebasic/docs/build` for the same documentation build
path. Use `dryRun: true` first when the user wants to review the command before
execution.

## Harness Execution Through MCP

The toolkit can run the fixed repository harness commands:

- `purebasic/test/run` -> `./tools/test.sh`
- `purebasic/build/run` -> `./tools/build.sh`
- `purebasic/check` -> `./tools/check.sh`
- `purebasic/docs/build` -> `./tools/build-docs.sh`

Each execution tool accepts:

- `dryRun`: boolean, default `false`
- `timeoutMs`: integer, default `300000`
- `maxOutputBytes`: integer, default `20000`

These tools intentionally do not accept arbitrary shell text. They are meant to
make the existing harness available to an MCP host while preserving the
repository's discipline: bounded output, explicit command identity, and
project-root path sanitization.

Run these tools sequentially. The underlying harness prepares shared `.local/`
toolchain homes, so launching multiple discovery/build/test paths at the same
time can produce filesystem races. For full verification, prefer
`purebasic/check` or `./tools/check.sh` as the single orchestrator.

## Lessons Learned As Defaults

- Do not commit workstation-specific absolute paths.
- Use repository-relative paths in tracked files.
- Treat `.pbp` as build target source of truth.
- Keep MCP stdout protocol-only.
- Send logs and diagnostics to stderr.
- Pair `ParseJSON()` and `CreateJSON()` ownership paths with `FreeJSON()`.
- Keep tests close to features.
- Do not assume docs, PDFs, packages, or checksums are current.
- Do not run harness setup scripts in parallel; `.local/` is shared generated
  state.
- Run the harness and report evidence.
