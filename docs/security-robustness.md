# Security And Robustness

This document records the generic JSON-RPC library boundaries. It is not a
security claim for every application built on top of the library.

## Library Responsibilities

The reusable `JSONRPC_*` layer is responsible for:

- rejecting malformed JSON-RPC messages predictably
- preserving ids only when they are valid JSON-RPC id values
- bounding framing and stdio message buffers
- keeping notification behavior response-free
- keeping batch response behavior compliant
- cleaning pending requests, cancellation state, queued writes, and trace state
  through documented lifecycle paths
- keeping trace payloads disabled unless explicitly enabled
- reporting write failures and orphan responses through diagnostics and events

## Application Responsibilities

Application and adapter layers are responsible for policy that JSON-RPC itself
does not define:

- filesystem access
- SQL execution
- command execution
- user approval
- host confirmation
- authentication
- authorization
- audit logging
- sandboxing

MCP examples in this repository demonstrate how a local server can use the
library, but they do not turn the generic JSON-RPC core into a sandbox.

## Trace Payloads

Trace capture is off by default. When trace is enabled, payloads remain hidden by
default. Callers must explicitly opt in to payload tracing.

This matters because JSON-RPC payloads can contain user data, local file names,
tool arguments, or application-specific secrets.

## Message Size Limits

The Content-Length frame reader and stdio codec both expose configurable message
limits. Oversized messages must be rejected before they are dispatched.

Default limits are intentionally conservative for local development and can be
made smaller in tests or application adapters.

## Absolute Path Hygiene

Tracked source, documentation, probes, and project files must use paths relative
to the repository root. Generated local output may contain real system paths, but
those paths must stay under ignored folders.

`tools/verify-paths.sh` scans tracked files for workstation-specific absolute
paths. `tools/check.sh` runs that scan before tests and builds.

## Error Text Boundaries

Generic JSON-RPC error responses should be useful but compact. They should not
dump long payloads, command output, SQL text, local absolute paths, or host
environment details.

Application-level tools may return richer details, but those tools must bound and
sanitize output according to their own policy.

## Robustness Verification

The robustness test route covers:

- trace payload opt-in behavior
- malformed-message recovery followed by a valid request
- write failure cleanup and recovery
- framing and stdio message size rejection
- tracked-file absolute path scanning

Required commands:

```sh
./tools/verify-paths.sh
./tools/test.sh
./tools/check.sh
```
