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
- Add API and Read the Docs scaffolding.

Acceptance criteria:

- `./tools/discover-purebasic.sh` detects PureBasic 6.40 and PureUnit.
- `./tools/test.sh` runs the PureUnit smoke test.
- `./tools/build.sh` builds `examples/000-project-foundation/console_probe.pb`.
- `./tools/check.sh` performs discovery, tests, build, and runs the example.

## Planned Build Order

1. Framed message reader and writer. Completed in `feature/001-framing`.
2. Transport codecs. Completed in `feature/002-transport-codecs`.
3. Connection lifecycle. Completed in `feature/003-connection-lifecycle`.
4. JSON parsing, validation, and standard errors. Completed in `feature/004-protocol-errors`.
5. Request and notification registration.
6. Inbound dispatch and response writing.
7. Outbound request ids and pending-response tracking.
8. Timeout housekeeping.
9. Batch handling.
10. Cooperative `$/cancelRequest` support.
11. Diagnostics counters.
12. Stress tests and memory lifecycle tests.

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
