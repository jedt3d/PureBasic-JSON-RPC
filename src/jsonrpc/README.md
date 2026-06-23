# JSON-RPC Library Source

This folder contains the PureBasic JSON-RPC library implementation.

Current library includes:

- `io.pbi` - generic reader and writer structures used by connection and tests.
- `byte_buffer.pbi` - explicit UTF-8 byte-counted buffer helper for codecs.
- `framing.pbi` - `Content-Length` frame writing and incremental frame reading.
- `codec.pbi` - MCP stdio newline-delimited message codec.
- `connection.pbi` - connection lifecycle, events, and generic writer support.
- `protocol.pbi` - JSON-RPC 2.0 message inspection and standard response builders.
- `dispatch.pbi` - request and notification handler registration and dispatch.
- `outbound.pbi` - outbound request ids, notifications, and pending response matching.
- `outbound.pbi` also owns pending request timeout cleanup.
- `batch.pbi` - sequential JSON-RPC batch dispatch.
- `cancel.pbi` - cooperative `$/cancelRequest` token handling.
- `diagnostics.pbi` - connection diagnostics counters and summary helpers.
- `stress.pbi` - bounded stress smoke helper for memory lifecycle paths.
- `stdio_runtime.pbi` - newline-delimited stdio runtime pump.
- `mcp_lifecycle.pbi` - MCP initialize and initialized adapter.
- `mcp_tools.pbi` - MCP tool metadata registry and `tools/list`.
- `mcp_tools.pbi` also provides MCP `tools/call` helpers.
- `jsonrpc.pbi` - consolidated include for the complete library stack.

PureUnit tests live under `tests/unit/`. PureUnit 1.4 currently does not discover `ProcedureUnit` tests reliably when module implementations are included from colocated test files, so the first library slice uses prefixed procedures such as `JSONRPC_Framing_BuildFrame()`.
