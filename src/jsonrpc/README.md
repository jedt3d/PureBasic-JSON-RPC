# JSON-RPC Library Source

This folder contains the PureBasic JSON-RPC library implementation.

Current library includes:

- `framing.pbi` - `Content-Length` frame writing and incremental frame reading.
- `codec.pbi` - MCP stdio newline-delimited message codec.
- `connection.pbi` - connection lifecycle and fake writer support.
- `protocol.pbi` - JSON-RPC 2.0 message inspection and standard response builders.
- `dispatch.pbi` - request and notification handler registration and dispatch.
- `outbound.pbi` - outbound request ids, notifications, and pending response matching.
- `outbound.pbi` also owns pending request timeout cleanup.
- `batch.pbi` - sequential JSON-RPC batch dispatch.
- `cancel.pbi` - cooperative `$/cancelRequest` token handling.

PureUnit tests live under `tests/unit/`. PureUnit 1.4 currently does not discover `ProcedureUnit` tests reliably when module implementations are included from colocated test files, so the first library slice uses prefixed procedures such as `JSONRPC_Framing_BuildFrame()`.
