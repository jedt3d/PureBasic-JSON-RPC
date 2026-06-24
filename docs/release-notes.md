# Release Notes

## Unreleased

Documentation and harness discipline:

- Added release quality gates for alpha, beta, and production-candidate
  readiness under `docs/release-quality-gates.md`.
- Added a JSON-RPC compliance matrix and expanded the reusable compliance runner
  with additional protocol edge cases.
- Hardened invalid `id` handling so object, array, and boolean ids return
  `-32600 Invalid Request` with `id: null` instead of reaching dispatch.
- Added lifecycle stress coverage for repeated dispatch, batch, timeout,
  cancellation, write queue, trace, and close cleanup behavior.
- Added security and robustness documentation plus a tracked-file path scanner
  that prevents workstation-specific absolute paths from entering the project.
- Added a release checklist and release artifact verifier so generated packages,
  documentation PDFs, manifests, and checksums are checked after packaging.
- Added a Thai code-level project walkthrough under `docs/Code Walkthrough.md`
  for reviewers who need to follow the source and examples from the beginning.
- Started the real `MCP/mcp-purebasic-toolkit` project with a stdio MCP server,
  read-only project/workflow/harness tools, bundled PureBasic development
  skills, separate toolkit milestones, and harness/package verification.
- Expanded `MCP/mcp-purebasic-toolkit` project intelligence with include graph,
  symbol search, procedure listing, `.pbp` target listing, probe coverage, and
  PureUnit coverage.
- Added bounded MCP toolkit harness execution tools for `./tools/test.sh`,
  `./tools/build.sh`, `./tools/check.sh`, and `./tools/build-docs.sh`, with
  `dryRun`, timeout limits, output bounds, and project-root path sanitization.
- Added MCP toolkit pair-development record tools for implementation briefs,
  algorithm explanations, and decision records, with optional `.local/` saves
  and filename/path validation.
- Added MCP toolkit Git/GitHub workflow helpers for read-only preflight,
  commit summary drafts, PR drafts, and release drafts without mutating Git or
  GitHub state.
- Added MCP toolkit documentation and milestone automation helpers for
  `005-docs-and-milestone-automation`: read-only route audits, route
  documentation update drafts, and milestone entry drafts that keep tracked
  source-of-truth edits under human review.
- Added MCP toolkit authoring helpers for `006-mcp-authoring-kit`: PureBasic
  stdio server scaffold drafts, tool handler drafts, JSONL probe drafts, and
  stdio transcript validation that rejects `Content-Length` framing for MCP
  stdio.
- Hardened `tools/test.sh` so multi-file runs execute PureUnit one file at a
  time, emit a summary report, clean up standby compiler processes after
  successful reports, and retry bounded pre-report hangs instead of letting
  `tools/check.sh` wait forever.
- Added `tools/verify-docs.sh` to verify numbered routes have matching example
  READMEs, API pages, milestone sections, API index entries, docs API bridge
  entries, and required Sphinx navigation.
- Wired documentation route verification into `./tools/check.sh`.
- Clarified in `AGENTS.md` and `docs/harness.md` that each route must update
  milestones, documentation navigation, release notes, and other source-of-truth
  documents before it is considered complete.
- Added a JSON-RPC-first release hardening plan for rounds `027` through `032`.

## 0.1.0-alpha.1

Initial macOS arm64 alpha target for the PureBasic JSON-RPC 2.0 library.

Highlights:

- JSON-RPC 2.0 parsing, dispatch, responses, notifications, and batches.
- Content-Length framing and newline-delimited stdio codec.
- Connection lifecycle, pending requests, timeouts, cancellation, diagnostics, events, write queue, and tracing.
- JSON-RPC compliance runner.
- MCP-oriented adapter previews for lifecycle and tools.
- Console, shared library, and app compile templates.
- Alpha source package generation with tarball manifest and SHA-256 checksum.

Status:

- API is alpha and may still evolve.
- Public procedure names are preferred stable surfaces.
- Public structure fields remain experimental unless documented otherwise.
