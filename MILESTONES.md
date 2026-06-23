# Milestones

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

## Planned Build Order

1. Framed message reader and writer. Completed in `feature/001-framing`.
2. Transport codecs. Completed in `feature/002-transport-codecs`.
3. Connection lifecycle. Completed in `feature/003-connection-lifecycle`.
4. JSON parsing, validation, and standard errors. Completed in `feature/004-protocol-errors`.
5. Request and notification registration. Completed in `feature/005-dispatch`.
6. Inbound dispatch and response writing. Started in `feature/005-dispatch`.
7. Outbound request ids and pending-response tracking. Completed in `feature/006-outbound-requests`.
8. Timeout housekeeping. Completed in `feature/007-timeout-housekeeping`.
9. Batch handling. Completed in `feature/008-batch-handling`.
10. Cooperative `$/cancelRequest` support. Completed in `feature/009-cancellation`.
11. Diagnostics counters. Completed in `feature/010-diagnostics`.
12. Stress tests and memory lifecycle tests. Completed in `feature/011-stress-memory`.
13. Stdio runtime pump. Completed in `feature/012-stdio-runtime-pump`.
14. MCP lifecycle adapter. Completed in `feature/013-mcp-lifecycle`.
15. MCP tools registry. Completed in `feature/014-mcp-tools-registry`.
16. MCP tools call. Completed in `feature/015-mcp-tools-call`.
17. Packaging and ReadTheDocs pass. Completed in `feature/016-packaging-docs`.

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
