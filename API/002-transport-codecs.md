# 002 Transport Codecs

Milestone `002-transport-codecs` adds MCP-compatible stdio message handling.

## Include

```purebasic
XIncludeFile "src/jsonrpc/codec.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_StdioCodecState
  buffer.s
  maxMessageBytes.i
  errorCode.i
  errorMessage.s
EndStructure
```

The codec reuses `JSONRPC_Message` from `framing.pbi`.

## Public Procedures

```purebasic
JSONRPC_Codec_StdioInit(*state, maxMessageBytes)
JSONRPC_Codec_StdioReset(*state)
JSONRPC_Codec_StdioPushBytes(*state, chunk.s)
JSONRPC_Codec_StdioNextMessage(*state, *message)
JSONRPC_Codec_StdioBuildMessage(body.s)
JSONRPC_Codec_StdioHasError(*state)
JSONRPC_Codec_StdioGetErrorCode(*state)
JSONRPC_Codec_StdioGetErrorMessage(*state)
```

## Behavior

- MCP stdio messages are UTF-8 JSON-RPC bodies delimited by a newline.
- `JSONRPC_Codec_StdioBuildMessage()` rejects outbound bodies containing `CR` or `LF`.
- `JSONRPC_Codec_StdioNextMessage()` strips the newline delimiter and an optional preceding `CR`.
- Embedded carriage returns are rejected.
- Oversized partial lines fail before unbounded buffer growth.

## Relationship To Framing

The existing `Content-Length` framing helpers remain available for vscode-jsonrpc/LSP-style transports. MCP stdio should use this newline codec.

