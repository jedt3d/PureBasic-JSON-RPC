# Release Hardening Plan

## Decision

Choose maturity first, then feature growth.

The project already has enough surface area for an alpha: a reusable JSON-RPC
core, transport codecs, connection lifecycle helpers, dispatch, outbound
requests, cancellation, diagnostics, tracing, a compliance runner, packaging,
documentation, and MCP-oriented examples. Adding more features before hardening
the JSON-RPC core would make later defects harder to isolate and would blur the
line between the reusable library and application-specific MCP servers.

The next phase should therefore be a JSON-RPC library hardening phase. The
primary scope is:

- `src/jsonrpc/`
- `tests/unit/`
- `API/`
- numbered examples under `examples/`
- release, package, documentation, and verification scripts under `tools/`
- source-of-truth planning documents under `docs/`

MCP examples remain useful dogfooding, but they are not the center of the next
quality track.

## What Went Wrong

The project briefly developed faster than its planning documents. The library
had completed implementation rounds beyond `016`, and MCP example work had been
tracked separately, but the central milestone document did not fully reflect
rounds `017` through `026` until it was corrected.

That was a process failure, not a protocol feature failure. The previous harness
verified builds, tests, projects, docs, PDFs, and packages, but it did not verify
that a completed numbered route had matching milestone, API index, docs index,
and release-route updates.

The correction is:

- every route must update code, tests, examples, API docs, milestones, indexes,
  release notes, and companion logs where relevant
- `AGENTS.md` now states that requirement explicitly
- `tools/verify-docs.sh` checks route-document consistency
- `tools/check.sh` runs that verification automatically

## Scope Boundary

The next work should be intentionally narrow.

In scope:

- JSON-RPC 2.0 protocol correctness
- malformed input behavior
- batch, notification, request, response, id, params, and error handling
- transport buffering and size limits
- connection lifecycle cleanup
- pending request and timeout behavior
- cancellation visibility
- trace payload controls
- public API stability
- release reproducibility

Out of scope for the next quality track:

- new MCP resources or prompts
- Streamable HTTP transport
- SQLite administrator policy controls
- richer spreadsheet/export features
- new production MCP example servers

Those features can resume after the core library has a stronger quality gate.

## Corrected 027-032 Track

### 027 Release Quality Gates

Purpose:

- Define what must be true before the library advances beyond alpha.
- Make readiness measurable instead of impression-based.
- Keep gates focused on the JSON-RPC library, not on application examples.

Required work:

- Add `docs/release-quality-gates.md`.
- Define alpha, beta, and production-readiness gates.
- Include protocol coverage, memory ownership, API stability, build
  reproducibility, documentation freshness, and packaging requirements.
- Link the document from `docs/index.md`, `docs/milestones.md`, and release
  notes.

Verification:

- `./tools/verify-docs.sh`
- `./tools/build-docs.sh`
- `./tools/check.sh`

### 028 Compliance Matrix

Purpose:

- Create a traceable map from JSON-RPC 2.0 requirements to implementation and
  tests.
- Make missing coverage visible before new feature work resumes.

Required work:

- Add `docs/jsonrpc-compliance-matrix.md`.
- Cover requests, notifications, responses, error objects, ids, params, parse
  errors, invalid requests, and batches.
- Link each rule to source files and tests, or mark it as a documented gap.
- Add small missing tests discovered during the matrix pass when they are
  low-risk.

Verification:

- `./tools/verify-docs.sh`
- `./tools/test.sh`
- `./tools/check.sh`

### 029 Negative Test Expansion

Purpose:

- Strengthen malformed-input and edge-case coverage.
- Confirm invalid input fails predictably and does not leak state.

Required work:

- Add tests for malformed JSON, invalid ids, invalid params, invalid batches,
  oversized payloads, embedded newline errors, orphan responses, and
  write-after-close cases.
- Confirm notifications still never produce responses.
- Confirm every new `ParseJSON()` and `CreateJSON()` path frees ownership
  correctly.

Verification:

- `./tools/test.sh`
- `./tools/check.sh`

### 030 Stress And Lifecycle Testing

Purpose:

- Exercise repeated use of the library under controlled pressure.
- Confirm cleanup behavior remains stable across many cycles.

Required work:

- Add stress loops for parse, dispatch, batch, cancellation, timeout, write,
  trace, and close cleanup.
- Confirm pending requests, cancellation state, queued writes, trace buffers,
  diagnostics counters, and buffers remain bounded.
- Keep stress tests deterministic enough for the normal local harness.

Verification:

- `./tools/test.sh`
- `./tools/build.sh`
- `./tools/check.sh`

### 031 Security And Robustness Review

Purpose:

- Document the generic library's security and robustness boundaries.
- Separate JSON-RPC library guarantees from application policy.

Required work:

- Add `docs/security-robustness.md`.
- Review message size limits, trace payload opt-in behavior, write failures,
  malformed-message recovery, and error text boundaries.
- Document that command execution, filesystem access, SQL safety, and host-level
  approval belong to MCP applications or callers, not the generic JSON-RPC core.
- Add tests for robustness boundaries that are cheap and deterministic.

Verification:

- `./tools/verify-docs.sh`
- `./tools/test.sh`
- `./tools/check.sh`

### 032 Release Automation Polish

Purpose:

- Make release creation repeatable, auditable, and resistant to stale
  documentation.

Required work:

- Add or update a release checklist under `docs/`.
- Confirm docs, PDFs, package manifests, checksums, `.pbp` metadata, examples,
  tests, and builds all come from the current tree.
- Confirm the package manifest includes current project docs and API pages.
- Keep generated PDFs as release artifacts, not committed binaries.

Verification:

- `./tools/verify-docs.sh`
- `./tools/build-docs.sh`
- `./tools/package-alpha.sh`
- `./tools/check.sh`

## Rule For New Features

New feature work should wait until rounds `027` through `032` are complete,
unless the change directly improves correctness, test coverage, release
repeatability, documentation accuracy, or robustness of the JSON-RPC library.

After this hardening track, feature work can resume on a stronger base. Good
future candidates include MCP resources, MCP prompts, Streamable HTTP transport,
stronger SQLite admin policy controls, richer export formatting, and additional
real MCP examples.

## Required Verification Habit

Every route should end with evidence, not only a summary. At minimum, report:

- branch name
- changed source/test/doc areas
- documentation route updates
- commands run
- test count or relevant check output
- remaining risks

The expected final verification for a completed route is:

```sh
./tools/verify-docs.sh
./tools/build-docs.sh
./tools/check.sh
```
