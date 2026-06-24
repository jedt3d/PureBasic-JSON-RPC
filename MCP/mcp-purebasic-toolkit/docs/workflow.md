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

## Lessons Learned As Defaults

- Do not commit workstation-specific absolute paths.
- Use repository-relative paths in tracked files.
- Treat `.pbp` as build target source of truth.
- Keep MCP stdout protocol-only.
- Send logs and diagnostics to stderr.
- Pair `ParseJSON()` and `CreateJSON()` ownership paths with `FreeJSON()`.
- Keep tests close to features.
- Do not assume docs, PDFs, packages, or checksums are current.
- Run the harness and report evidence.
