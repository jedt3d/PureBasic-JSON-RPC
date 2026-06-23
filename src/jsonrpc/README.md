# JSON-RPC Library Source

This folder contains the PureBasic JSON-RPC library implementation.

Current library includes:

- `framing.pbi` - `Content-Length` frame writing and incremental frame reading.
- `codec.pbi` - MCP stdio newline-delimited message codec.
- `connection.pbi` - connection lifecycle and fake writer support.

PureUnit tests live under `tests/unit/`. PureUnit 1.4 currently does not discover `ProcedureUnit` tests reliably when module implementations are included from colocated test files, so the first library slice uses prefixed procedures such as `JSONRPC_Framing_BuildFrame()`.
