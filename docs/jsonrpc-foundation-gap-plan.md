# JSON-RPC Foundation Gap Plan

This note records the main generic JSON-RPC gaps to keep in view before calling
the library production-ready. It is not a commitment to implement everything
immediately.

The scope of this plan is the reusable JSON-RPC layer only. MCP adapters, MCP
schemas, and MCP-specific features should build on top of this foundation rather
than drive these rounds directly.

## Reference Baseline

- JSON-RPC 2.0 specification: https://www.jsonrpc.org/specification
- vscode-jsonrpc package: https://www.npmjs.com/package/vscode-jsonrpc
- vscode-jsonrpc source: https://github.com/microsoft/vscode-languageserver-node/tree/main/jsonrpc

## Current Position

The library now has a usable generic JSON-RPC base:

- Content-Length framing helpers.
- newline-delimited stdio codec support.
- message inspection and standard error builders.
- request and notification dispatch.
- outbound request tracking.
- timeout cleanup.
- sequential batch dispatch.
- cooperative cancellation state.
- diagnostics counters.
- stress tests and packaging templates.

This is enough for controlled local examples and early adapter work. The
completed 017-026 rounds addressed the first major foundation gaps: transport
interfaces, byte-buffer state, events, handler lifecycle, cancellation tokens,
write queues, trace hooks, compliance tests, API review, and alpha packaging.

The next improvements should now focus on release quality gates, deeper
compliance evidence, negative testing, stress/lifecycle testing, robustness, and
release automation polish.

## Main Gaps

### Real Reader And Writer Abstractions

The connection still depends heavily on fake-writer-style testing and feed-style runtime entrypoints. A production JSON-RPC foundation should expose real reader and writer interfaces for stdin/stdout, files, pipes, sockets, and in-memory tests.

The target should be a transport-neutral connection that owns a reader, writer, dispatcher, pending request map, diagnostics, and lifecycle callbacks.

### Byte-Safe Buffering

Some current buffering paths are string-oriented. That is acceptable for controlled UTF-8 examples, but raw streams can split bytes in the middle of UTF-8 sequences or headers.

The next transport layer should use explicit byte buffers, bounded growth, and deterministic parse states.

### Write Queue And Backpressure

The current writer path appends captured bodies and guards writes with a mutex. A production writer should provide a queued write path with clear behavior for partial writes, closed streams, failed writes, and flush/end semantics.

This is especially important before adding sockets, pipes, or long-running subprocess communication.

### Connection Lifecycle Events

The library has running, closing, and closed flags, but it does not yet expose a full lifecycle event model.

Useful generic events include:

- read error
- write error
- malformed message
- unhandled notification
- orphan response
- close
- dispose

Handlers should be able to observe these without mixing transport logging into protocol dispatch.

### Handler Registration Lifecycle

Request and notification registration works, but handlers are not yet disposable and replacement behavior is not fully formalized.

Future code should define:

- duplicate registration policy
- unregister/dispose API
- optional catch-all request handler
- optional catch-all notification handler
- stable handler ownership rules

### Handler-Side Cancellation Tokens

Cancellation is currently recorded as state for an id. It should be propagated into request handlers as a token they can check cooperatively.

The token does not need to kill threads. It should provide a stable API for "is cancellation requested" and cleanup after request completion.

### Error Boundaries

Handler failures should be converted into predictable JSON-RPC error responses. Internal library errors should be distinguishable from handler-declared protocol errors.

The foundation should document when to return:

- parse error
- invalid request
- method not found
- invalid params
- internal error
- application-defined server errors

### Progress And Protocol Extension Hooks

Base JSON-RPC has no progress concept, but vscode-jsonrpc-style runtimes commonly support extension notifications such as progress and tracing.

The generic foundation should not bake in one application protocol, but it should make extension-style notifications easy to register, send, trace, and test.

### Structured Logging And Trace

Diagnostics counters exist, but there is no structured logger or trace control. Production users need a way to inspect traffic and failures without printing protocol noise to stdout.

Tracing should support at least:

- off
- errors
- headers and message sizes
- compact messages
- verbose messages

Sensitive payload handling should be caller-controlled.

### Compliance And Interop Test Suite

The current tests cover many local paths. A stronger foundation needs a reusable JSON-RPC compliance suite built from official examples and generated edge cases.

Coverage should include:

- id preservation
- notifications never responding
- invalid batch shapes
- malformed JSON loops
- mixed request/notification batches
- response matching and orphan responses
- transport framing edge cases

### API Stability And Versioning

The API is still alpha. Before production, public structures and procedures should be reviewed for compatibility risk.

The library needs:

- stable include entrypoints
- documented public/private symbols
- semantic versioning policy
- changelog convention
- migration notes for breaking changes

## Completed JSON-RPC-Only Rounds

### 017 Reader And Writer Interfaces

Add generic `JSONRPC_Reader_*` and `JSONRPC_Writer_*` interfaces, keeping fake reader/writer implementations for tests.

Definition of done:

- existing tests still pass
- fake writer is moved behind the same public writer shape
- connection code no longer knows about a fake-writer-specific structure
- API docs explain how a transport plugs in

### 018 Byte Buffer Framing Runtime

Replace string-oriented incremental framing paths with byte-buffer state machines for Content-Length and newline-delimited codecs.

Definition of done:

- partial header reads work
- partial body reads work
- bounded buffers reject oversized messages
- UTF-8 body text is only interpreted after complete message extraction

### 019 Connection Event Model

Add lightweight connection events or callback slots for close, error, orphan response, unhandled notification, and malformed message.

Definition of done:

- tests can observe each event
- event callbacks do not allocate long-lived JSON state
- dispatch behavior remains unchanged unless a handler is registered

### 020 Handler Registration Lifecycle

Add disposable/unregister support for request and notification handlers, plus documented duplicate registration behavior.

Definition of done:

- registering a duplicate method has deterministic behavior
- unregistering a handler prevents future dispatch
- unknown request and unknown notification behavior remains JSON-RPC compliant

### 021 Handler Cancellation Tokens

Pass a cooperative cancellation token into request context and expose helper functions for handler code.

Definition of done:

- `$/cancelRequest` marks a token visible to the matching handler
- completing a request clears cancellation state
- cancellation never sends a response by itself

### 022 Write Queue And Close Semantics

Introduce a queued writer path and formalize writes during closing, after close, and after writer errors.

Definition of done:

- write failure increments diagnostics
- write-after-close is rejected consistently
- close drains or drops pending writes according to documented policy

### 023 Trace And Logger Hooks

Add caller-provided logging and trace hooks that are transport-safe.

Definition of done:

- no protocol logs are written directly to stdout
- trace levels are testable
- payload tracing can be disabled independently from error tracing

### 024 Compliance Suite

Create a dedicated JSON-RPC compliance test module and example runner.

Definition of done:

- official JSON-RPC examples are represented
- generated invalid-message cases are covered
- compliance tests are reusable by future transport/adapters

### 025 Public API Review

Review public symbols and decide what remains stable for a first alpha tag.

Definition of done:

- public/private symbol guidance is documented
- compatibility shims are added where needed
- release notes identify unstable APIs

### 026 macOS arm64 Alpha Release Package

Create a JSON-RPC-only alpha release package for macOS arm64.

Definition of done:

- `./tools/check.sh` passes
- docs build warning-free
- package includes source, examples, API docs, and checksums
- macOS x64 is compile-smoke-tested as available, but not release-blocking

## Suggested Immediate Next Step

Rounds 017-026 are complete. The next phase should start with round 027 and keep
the center of gravity on the JSON-RPC library source and tests.

Round 027 should not add protocol features. It should define release quality
gates so later hardening work can be measured against explicit criteria.

## Recommended Next JSON-RPC Hardening Rounds

### 027 Release Quality Gates

Define the quality bar for alpha, beta, and production readiness.

Definition of done:

- quality gates are documented in `docs/release-quality-gates.md`
- JSON-RPC source, test, documentation, package, and API stability gates are
  explicit
- MCP examples are identified as dogfooding evidence, not the primary gate for
  generic JSON-RPC correctness

### 028 Compliance Matrix Expansion

Create a traceable matrix from JSON-RPC 2.0 rules to tests and source behavior.

Definition of done:

- each core protocol rule has a test reference or a documented gap
- request, response, notification, error, id, params, and batch behavior are
  covered
- missing high-value tests are added when cheap and low-risk

### 029 Negative Test Expansion

Add malformed-input and edge-case coverage around the library core.

Definition of done:

- invalid JSON, invalid ids, invalid params, invalid batches, oversized payloads,
  and orphan responses are covered
- notification no-response behavior is preserved
- JSON allocation/free behavior remains paired in new paths

### 030 Stress And Lifecycle Testing

Increase repeated-use testing for connection and protocol lifecycle behavior.

Definition of done:

- stress loops cover parse, dispatch, batch, cancellation, timeout, write, trace,
  and close cleanup
- pending requests, cancellations, queued writes, trace buffers, and diagnostics
  remain bounded and clean

### 031 Security And Robustness Review

Document and test the generic library's robustness boundaries.

Definition of done:

- message limits, trace payload controls, write failures, malformed-message
  recovery, and error boundaries are reviewed
- application-level policy such as SQL, filesystem, and command execution is
  clearly separated from the generic JSON-RPC library

### 032 Release Automation Polish

Make the release loop repeatable and stale-document-resistant.

Definition of done:

- release checklist is documented
- docs, PDFs, package manifests, checksums, `.pbp` metadata, tests, and builds
  are verified from the current tree
- the next alpha or beta candidate process is clear
