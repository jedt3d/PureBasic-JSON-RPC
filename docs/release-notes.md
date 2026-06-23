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
