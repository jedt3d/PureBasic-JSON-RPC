# API Stability

This project is in alpha.

Prefer public procedures over direct structure field access. Structure fields remain visible because this is PureBasic, but they should be treated as implementation details unless an API page explicitly documents field ownership.

## Alpha Rules

- Additive changes are preferred.
- Breaking procedure changes require a compatibility shim when practical.
- MCP adapter APIs are less stable than generic `JSONRPC_*` APIs.
- Version metadata is exposed through `JSONRPC_LibraryVersion()`.

## Current Version

`0.1.0-alpha.1`
