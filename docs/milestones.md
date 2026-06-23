# Milestones

This file tracks the numbered JSON-RPC foundation milestones. The main product
direction remains MCP-friendly PureBasic development, but the numbered milestone
track is about the reusable `src/jsonrpc/` library and its tests first.

The later MCP-focused example and export work is tracked separately in
`docs/mcp-example-milestone-log.md`. That work is valuable dogfooding, but it is
not a substitute for maturing the JSON-RPC library source, protocol compliance,
and test coverage.

## 000-project-foundation

Branch: `feature/000-project-foundation`

Purpose:

- Establish AI/contributor guidance in `AGENTS.md`.
- Discover PureBasic 6.40 and SDK PureUnit.
- Create project-local generated homes under `.local/`.
- Add build, test, and check scripts.
- Add the first PureUnit smoke test.
- Add the first scenario console application.
- Add committed `.pbp` project metadata for buildable scenario targets.
- Add API and Read the Docs scaffolding.

Acceptance criteria:

- `./tools/discover-purebasic.sh` detects PureBasic 6.40 and PureUnit.
- `./tools/test.sh` runs the PureUnit smoke test.
- `./tools/verify-projects.sh` verifies `.pbp` target metadata.
- `./tools/build.sh` builds scenario targets through their `.pbp` files.
- `./tools/check.sh` performs discovery, tests, build, and runs the example.

## Completed Build Order

0. Project foundation. Completed in `feature/000-project-foundation`.
1. Framed message reader and writer. Completed in `feature/001-framing`.
2. Transport codecs. Completed in `feature/002-transport-codecs`.
3. Connection lifecycle. Completed in `feature/003-connection-lifecycle`.
4. JSON parsing, validation, and standard errors. Completed in `feature/004-protocol-errors`.
5. Request and notification registration. Completed in `feature/005-dispatch`.
6. Outbound request ids and pending-response tracking. Completed in `feature/006-outbound-requests`.
7. Timeout housekeeping. Completed in `feature/007-timeout-housekeeping`.
8. Batch handling. Completed in `feature/008-batch-handling`.
9. Cooperative `$/cancelRequest` support. Completed in `feature/009-cancellation`.
10. Diagnostics counters. Completed in `feature/010-diagnostics`.
11. Stress tests and memory lifecycle tests. Completed in `feature/011-stress-memory`.
12. Stdio runtime pump. Completed in `feature/012-stdio-runtime-pump`.
13. MCP lifecycle adapter. Completed in `feature/013-mcp-lifecycle`.
14. MCP tools registry. Completed in `feature/014-mcp-tools-registry`.
15. MCP tools call. Completed in `feature/015-mcp-tools-call`.
16. Packaging and ReadTheDocs pass. Completed in `feature/016-packaging-docs`.
17. Reader and writer interfaces. Completed in `feature/017-reader-writer-interfaces`.
18. Byte buffer framing runtime. Completed in `feature/018-byte-buffer-framing`.
19. Connection event model. Completed in `feature/019-connection-events`.
20. Handler registration lifecycle. Completed in `feature/020-handler-registration-lifecycle`.
21. Handler cancellation tokens. Completed in `feature/021-handler-cancellation-tokens`.
22. Write queue and close semantics. Completed in `feature/022-write-queue-close-semantics`.
23. Trace and logger hooks. Completed in `feature/023-trace-logger-hooks`.
24. JSON-RPC compliance suite. Completed in `feature/024-compliance-suite`.
25. Public API review. Completed in `feature/025-public-api-review`.
26. Alpha release package. Completed in `feature/026-alpha-release-package`.

## Next Quality Track

The next phase should focus on hardening the JSON-RPC library before adding more
features. MCP examples can continue to exist as proof points, but rounds 027-032
should prioritize `src/jsonrpc/`, `tests/unit/`, protocol behavior, and release
quality. The narrative rationale and verification habit are captured in
`docs/release-hardening-plan.md`.

27. Release quality gates. Completed in `feature/027-release-quality-gates`.
28. JSON-RPC compliance matrix expansion. Completed in `feature/028-compliance-matrix`.
29. Negative test expansion. Completed in `feature/029-negative-tests`.
30. Stress and lifecycle testing. Completed in `feature/030-stress-lifecycle`.
31. Security and robustness review. Planned as `feature/031-security-robustness`.
32. Release automation polish. Planned as `feature/032-release-automation-polish`.

## 001-framing

Branch: `feature/001-framing`

Purpose:

- Add the first reusable `Content-Length` framing helpers.
- Build frames with UTF-8 byte lengths.
- Incrementally collect stream chunks and extract complete message bodies.
- Preserve bytes after the first message for subsequent reads.
- Reject missing, duplicate, invalid, or oversized `Content-Length` headers.

Acceptance criteria:

- PureUnit covers fragmented headers, fragmented bodies, multiple frames, Unicode byte lengths, invalid lengths, and body limits.
- `examples/001-framing/framing_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 002-transport-codecs

Branch: `feature/002-transport-codecs`

Purpose:

- Add MCP-compatible stdio newline-delimited message handling.
- Keep existing Content-Length framing helpers available.
- Reject outbound messages containing embedded line breaks.
- Bound stdio message buffers.

Acceptance criteria:

- PureUnit covers partial lines, multiple lines, CRLF delimiters, embedded newline rejection, and oversized lines.
- `examples/002-transport-codecs/stdio_codec_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 003-connection-lifecycle

Branch: `feature/003-connection-lifecycle`

Purpose:

- Add connection lifecycle state.
- Add fake writer capture for deterministic tests.
- Make close idempotent.
- Reject writes after close.

Acceptance criteria:

- PureUnit covers create, close twice, missing writer, fake writer capture, and post-close rejection.
- `examples/003-connection-lifecycle/connection_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 004-protocol-errors

Branch: `feature/004-protocol-errors`

Purpose:

- Add JSON-RPC 2.0 message inspection.
- Add standard error and result response builders.
- Preserve ids where they can be safely detected.
- Keep JSON parsing/freeing localized.

Acceptance criteria:

- PureUnit covers parse error, invalid request, invalid params, notifications, valid requests, response exclusivity, id preservation, result response, and method-not-found response.
- `examples/004-protocol-errors/spec_examples_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 005-dispatch

Branch: `feature/005-dispatch`

Purpose:

- Add request and notification handler registration.
- Add dispatch for requests, notifications, unknown methods, and handler errors.
- Add response writing through the fake connection writer.

Acceptance criteria:

- PureUnit covers request response, dispatch-to-connection writing, notification params/no-response behavior, unknown request, unknown notification, and handler invalid params.
- `examples/005-dispatch/dispatch_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 006-outbound-requests

Branch: `feature/006-outbound-requests`

Purpose:

- Add outbound request and notification builders.
- Add connection-level request id allocation.
- Track pending outbound requests until a matching response arrives.
- Ignore orphan responses without disturbing pending requests.
- Clear pending state during connection close.

Acceptance criteria:

- PureUnit covers request send, notification send, response matching, orphan response handling, invalid params rejection, and close cleanup.
- `examples/006-outbound-requests/outbound_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 007-timeout-housekeeping

Branch: `feature/007-timeout-housekeeping`

Purpose:

- Add per-request timeout fields to pending outbound requests.
- Use a default timeout of `30000` milliseconds.
- Allow request-level timeout override.
- Remove expired pending requests during cleanup.

Acceptance criteria:

- PureUnit covers default deadline, custom timeout expiry, fresh request preservation, and matched-response cleanup.
- `examples/007-timeout-housekeeping/timeout_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 008-batch-handling

Branch: `feature/008-batch-handling`

Purpose:

- Add sequential JSON-RPC batch dispatch.
- Return invalid request for empty batches.
- Suppress notification responses inside batches.
- Return arrays only when at least one batch item requires a response.

Acceptance criteria:

- PureUnit covers empty batch, notification-only batch, mixed batch, single-message fallback, and connection writing.
- `examples/008-batch-handling/batch_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 009-cancellation

Branch: `feature/009-cancellation`

Purpose:

- Add cooperative `$/cancelRequest` notification handling.
- Store cancellation tokens on the connection.
- Allow handlers to query and clear cancellation state.
- Clear cancellation state on connection close.

Acceptance criteria:

- PureUnit covers numeric and string id cancellation, clearing, ignored invalid notifications, and close cleanup.
- `examples/009-cancellation/cancel_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 010-diagnostics

Branch: `feature/010-diagnostics`

Purpose:

- Add connection-level diagnostics counters.
- Count sends, inbound messages, errors, timeouts, orphan responses, batches, and cancellations.
- Add snapshot, reset, and compact summary helpers.

Acceptance criteria:

- PureUnit covers send/receive/error counters, timeout/orphan/batch/cancel counters, and reset behavior.
- `examples/010-diagnostics/diagnostics_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 011-stress-memory

Branch: `feature/011-stress-memory`

Purpose:

- Add bounded repeated parse and dispatch stress coverage.
- Exercise malformed messages, timeout cleanup, notification-only batches, and cancellation cleanup.
- Confirm stress loops leave no pending request state.

Acceptance criteria:

- PureUnit covers malformed-message loops, timeout cleanup loops, batch/cancellation loops, and the reusable stress helper.
- `examples/011-stress-memory/stress_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 012-stdio-runtime-pump

Branch: `feature/012-stdio-runtime-pump`

Purpose:

- Add a reusable stdio message pump over the newline codec.
- Route responses to pending request matching.
- Route batches, requests, notifications, and cancellation messages through existing layers.

Acceptance criteria:

- PureUnit covers request dispatch, partial lines, response matching, batch dispatch, and cancellation notifications.
- `examples/012-stdio-runtime-pump/stdio_runtime_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 013-mcp-lifecycle

Branch: `feature/013-mcp-lifecycle`

Purpose:

- Add MCP lifecycle adapter registration.
- Support `initialize` and `notifications/initialized`.
- Return protocol version, server info, capabilities, and optional instructions.

Acceptance criteria:

- PureUnit covers initialize result, missing protocol version, and initialized notification.
- `examples/013-mcp-lifecycle/mcp_lifecycle_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 014-mcp-tools-registry

Branch: `feature/014-mcp-tools-registry`

Purpose:

- Add MCP tool metadata registry.
- Add `tools/list` handler registration.
- Add `notifications/tools/list_changed` notification builder.

Acceptance criteria:

- PureUnit covers tool registration validation, listed tool metadata, empty registry, and list-changed notification shape.
- `examples/014-mcp-tools-registry/mcp_tools_list_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 015-mcp-tools-call

Branch: `feature/015-mcp-tools-call`

Purpose:

- Add MCP `tools/call` handler registration.
- Pass tool arguments to registered handlers.
- Add text result helper and execution-error result support.
- Return JSON-RPC `-32602` for unknown tools or malformed call params.

Acceptance criteria:

- PureUnit covers successful tool call, unknown tool, invalid arguments, and tool execution error result.
- `examples/015-mcp-tools-call/mcp_tools_call_probe.pb` builds and runs.
- `./tools/check.sh` passes.

## 016-packaging-docs

Branch: `feature/016-packaging-docs`

Purpose:

- Add consolidated include `src/jsonrpc/jsonrpc.pbi`.
- Add console, shared library, and app compile templates.
- Add ReadTheDocs navigation to the API index.

Acceptance criteria:

- PureUnit covers consolidated include exposure.
- `examples/016-packaging-docs/package_probe.pb` builds and runs.
- Console, shared library, and app templates compile.
- `./tools/check.sh` passes.

## 017-reader-writer-interfaces

Branch: `feature/017-reader-writer-interfaces`

Purpose:

- Add transport-neutral reader and writer structures.
- Move fake writer behavior behind the generic writer shape.
- Add an in-memory reader fixture for deterministic transport tests.
- Keep existing connection tests compatible while reducing fake-writer coupling.

Acceptance criteria:

- PureUnit covers writer initialization, close behavior, captured writes, simulated write failure, and reader buffering.
- `examples/017-reader-writer-interfaces/reader_writer_probe.pb` builds and runs.
- API documentation exists in `API/017-reader-writer-interfaces.md`.
- `./tools/check.sh` passes.

## 018-byte-buffer-framing

Branch: `feature/018-byte-buffer-framing`

Purpose:

- Add explicit byte-buffer state for transport buffering.
- Route Content-Length framing state through the byte buffer helper.
- Route stdio codec state through the byte buffer helper.
- Preserve external framing and codec procedure compatibility.

Acceptance criteria:

- PureUnit covers UTF-8 byte length counting, bounded appends, overflow behavior, framing compatibility, and stdio codec compatibility.
- `examples/018-byte-buffer-framing/byte_buffer_probe.pb` builds and runs.
- API documentation exists in `API/018-byte-buffer-framing.md`.
- `./tools/check.sh` passes.

## 019-connection-events

Branch: `feature/019-connection-events`

Purpose:

- Add optional connection lifecycle and protocol event observation.
- Record close, malformed message, unhandled notification, orphan response, and error events.
- Keep event details short and independent from long-lived JSON state.
- Preserve existing dispatch behavior when no event handler is registered.

Acceptance criteria:

- PureUnit covers callback invocation, last-event storage, malformed message events, unhandled notification events, orphan response events, and close/dispose events.
- `examples/019-connection-events/connection_events_probe.pb` builds and runs.
- API documentation exists in `API/019-connection-events.md`.
- `./tools/check.sh` passes.

## 020-handler-registration-lifecycle

Branch: `feature/020-handler-registration-lifecycle`

Purpose:

- Formalize handler replacement behavior.
- Add unregister helpers for request and notification handlers.
- Add exact-handler lookup helpers.
- Add catch-all request and notification handlers.

Acceptance criteria:

- PureUnit covers duplicate registration policy, replacement disabled behavior, unregister behavior, handler existence checks, and catch-all dispatch.
- `examples/020-handler-registration-lifecycle/handler_lifecycle_probe.pb` builds and runs.
- API documentation exists in `API/020-handler-registration-lifecycle.md`.
- `./tools/check.sh` passes.

## 021-handler-cancellation-tokens

Branch: `feature/021-handler-cancellation-tokens`

Purpose:

- Expose cooperative cancellation state to request handlers through request context.
- Let handlers query whether cancellation was requested for the current id.
- Clear matching cancellation state after request completion.
- Keep cancellation cooperative; it does not kill threads or force a response.

Acceptance criteria:

- PureUnit covers numeric and string cancellation ids, context-visible cancellation, cleanup after completion, and ignored invalid cancellation notifications.
- `examples/021-handler-cancellation-tokens/cancellation_tokens_probe.pb` builds and runs.
- API documentation exists in `API/021-handler-cancellation-tokens.md`.
- `./tools/check.sh` passes.

## 022-write-queue-close-semantics

Branch: `feature/022-write-queue-close-semantics`

Purpose:

- Add explicit queued write behavior behind connection sending.
- Define write-after-close and write-during-close behavior.
- Count queued writes and write failures in diagnostics.
- Drop failed queued bodies predictably after a writer failure.

Acceptance criteria:

- PureUnit covers queued sends, flush behavior, write failure diagnostics, pending write counts, close cleanup, and closed-write rejection.
- `examples/022-write-queue-close-semantics/write_queue_probe.pb` builds and runs.
- API documentation exists in `API/022-write-queue-close-semantics.md`.
- `./tools/check.sh` passes.

## 023-trace-logger-hooks

Branch: `feature/023-trace-logger-hooks`

Purpose:

- Add transport-safe trace capture on the connection.
- Add optional caller-provided trace logger callbacks.
- Keep tracing disabled by default.
- Keep payload logging opt-in so protocol data is not leaked accidentally.

Acceptance criteria:

- PureUnit covers trace levels, captured trace output, logger callbacks, payload-hidden defaults, payload opt-in behavior, and write-failure tracing.
- `examples/023-trace-logger-hooks/trace_logger_probe.pb` builds and runs.
- API documentation exists in `API/023-trace-logger-hooks.md`.
- `./tools/check.sh` passes.

## 024-compliance-suite

Branch: `feature/024-compliance-suite`

Purpose:

- Add a reusable JSON-RPC core compliance runner.
- Represent official-style request, notification, parse error, invalid request, and batch cases.
- Keep the suite generic and independent from MCP schemas.
- Make compliance results queryable from tests and examples.

Acceptance criteria:

- PureUnit covers the compliance runner, pass/fail reporting, official-style examples, notification no-response behavior, batch edge cases, and response id matching.
- `examples/024-compliance-suite/compliance_probe.pb` builds and runs.
- API documentation exists in `API/024-compliance-suite.md`.
- `./tools/check.sh` passes.

## 025-public-api-review

Branch: `feature/025-public-api-review`

Purpose:

- Document the first alpha API stability contract.
- Add library metadata helpers for name, version, and status.
- Identify stable and experimental API families for the alpha line.
- Define the compatibility rule for future alpha changes.

Acceptance criteria:

- PureUnit covers library metadata helpers.
- `examples/025-public-api-review/api_review_probe.pb` builds and runs.
- API documentation exists in `API/025-public-api-review.md`.
- Release notes identify alpha API status.
- `./tools/check.sh` passes.

## 026-alpha-release-package

Branch: `feature/026-alpha-release-package`

Purpose:

- Add repeatable alpha source packaging.
- Stage source, tests, examples, tools, API docs, and project docs.
- Generate package manifest and SHA-256 checksums.
- Include long-form PDF documentation as release artifacts.

Acceptance criteria:

- `./tools/package-alpha.sh` creates the source archive, checksum, manifest, and PDF artifacts under `.build/dist/`.
- PureUnit covers release metadata and alpha package probe behavior.
- `examples/026-alpha-release-package/alpha_package_probe.pb` builds and runs.
- API documentation exists in `API/026-alpha-release-package.md`.
- `./tools/check.sh` passes.

## 027-release-quality-gates

Branch: `feature/027-release-quality-gates`

Status: completed

Purpose:

- Define what must be true before the JSON-RPC library advances beyond alpha.
- Make release readiness measurable instead of impression-based.
- Keep quality gates focused on `src/jsonrpc/`, `tests/unit/`, `API/`, and release automation.
- Treat MCP examples as secondary dogfooding, not release blockers for generic JSON-RPC correctness.

Acceptance criteria:

- Add `docs/release-quality-gates.md`.
- Define alpha, beta, and production-readiness gates.
- Add a checkable list for protocol coverage, memory ownership, API stability, build reproducibility, and documentation freshness.
- Link the quality gates from this milestone document and the release notes.
- `./tools/check.sh` passes.

## 028-compliance-matrix

Branch: `feature/028-compliance-matrix`

Status: completed

Purpose:

- Build a traceable JSON-RPC 2.0 compliance matrix.
- Map each protocol rule to source files, tests, examples, and API documentation.
- Make missing coverage visible before adding new features.
- Keep MCP-specific behavior out of the generic matrix except where it exercises base JSON-RPC transport rules.

Acceptance criteria:

- Add `docs/jsonrpc-compliance-matrix.md`.
- Cover requests, notifications, responses, ids, params, parse errors, invalid requests, error objects, and batches.
- Link each matrix row to at least one test or mark it as a documented gap.
- Add or update tests for any easy missing coverage found during the matrix pass.
- `./tools/check.sh` passes.

## 029-negative-tests

Branch: `feature/029-negative-tests`

Status: completed

Purpose:

- Expand negative and malformed-input coverage.
- Verify that invalid input fails predictably without leaking state.
- Strengthen boundary tests for codecs, protocol validation, dispatch, pending responses, and batches.
- Keep tests deterministic and fast enough for the normal harness.

Acceptance criteria:

- Add malformed JSON, invalid id, invalid params, invalid batch, oversized message, and unmatched response tests.
- Confirm notifications still never produce responses.
- Confirm every parse/create JSON path used by new tests frees JSON state.
- Update compliance documentation for new coverage.
- `./tools/check.sh` passes.

## 030-stress-lifecycle

Branch: `feature/030-stress-lifecycle`

Status: completed

Purpose:

- Increase stress coverage for repeated parse, dispatch, write, close, and cleanup cycles.
- Verify bounded buffers and stable counters under repeated use.
- Exercise timeout, cancellation, pending response, trace, and queued write cleanup together.
- Keep the stress suite library-focused rather than example-focused.

Acceptance criteria:

- Add stress loops for repeated valid messages, malformed messages, mixed batches, orphan responses, cancellation notifications, and write failures.
- Confirm pending requests, cancellation state, queued writes, trace buffers, and diagnostics reset or clean up as documented.
- Add an example stress probe only if it helps reproduce a library-level lifecycle case.
- `./tools/check.sh` passes.

## 031-security-robustness

Branch: `feature/031-security-robustness`

Status: planned

Purpose:

- Review robustness boundaries in the generic library.
- Verify message size limits, trace payload controls, stdout safety expectations, and error message boundaries.
- Document what the JSON-RPC library guarantees and what application/adapters must enforce.
- Avoid turning example-server policy into generic JSON-RPC policy.

Acceptance criteria:

- Add `docs/security-robustness.md`.
- Add tests for maximum message sizes, trace payload opt-in, write failures, and malformed-message recovery.
- Document that command execution, filesystem policy, and SQL safety belong to application-level MCP servers, not the generic JSON-RPC core.
- `./tools/check.sh` passes.

## 032-release-automation-polish

Branch: `feature/032-release-automation-polish`

Status: planned

Purpose:

- Make release automation boring, repeatable, and auditable.
- Ensure docs, PDFs, manifests, checksums, project files, tests, builds, and package artifacts are all generated from the latest tree.
- Reduce chances of stale docs or stale package contents.
- Prepare the next alpha or beta candidate process.

Acceptance criteria:

- Add or update a release checklist under `docs/`.
- Ensure `./tools/check.sh` verifies docs and package freshness from the current source tree.
- Confirm package manifests include moved project docs and current API pages.
- Confirm `.pbp` project verification remains part of normal checks.
- `./tools/check.sh` passes.
