# 001 Framing

Milestone `001-framing` introduces the first public library include: `framing.pbi`.

## Include

```purebasic
XIncludeFile "src/jsonrpc/framing.pbi"
```

## Naming

The framing API uses `JSONRPC_Framing_`-prefixed procedures and `JSONRPC_`-prefixed structures.

This include does not parse JSON and does not dispatch methods. It only converts message bodies to framed strings and extracts complete bodies from an incremental stream buffer.

## Public Structures

```purebasic
Structure JSONRPC_FrameState
  buffer.s
  maxHeaderBytes.i
  maxBodyBytes.i
  errorCode.i
  errorMessage.s
EndStructure

Structure JSONRPC_Message
  body.s
  byteLength.i
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Framing_Init(*state, maxHeaderBytes, maxBodyBytes)
JSONRPC_Framing_Reset(*state)
JSONRPC_Framing_PushBytes(*state, chunk.s)
JSONRPC_Framing_NextMessage(*state, *message)
JSONRPC_Framing_BuildFrame(body.s)
JSONRPC_Framing_Utf8ByteLength(text.s)
JSONRPC_Framing_HasError(*state)
JSONRPC_Framing_GetErrorCode(*state)
JSONRPC_Framing_GetErrorMessage(*state)
```

## Behavior

- `JSONRPC_Framing_BuildFrame()` prefixes a body with `Content-Length: <utf8-byte-length>` and a blank `CRLF` line.
- `JSONRPC_Framing_PushBytes()` appends a stream chunk to the frame state.
- `JSONRPC_Framing_NextMessage()` returns `#True` only when one complete body is available.
- Any bytes after a complete body remain buffered for the next `JSONRPC_Framing_NextMessage()` call.
- Invalid framing sets an error state that can be inspected with `JSONRPC_Framing_GetErrorCode()` and `JSONRPC_Framing_GetErrorMessage()`.

## Limits

The default header limit is `8192` bytes. The default body limit is `1048576` bytes.

## Current Limitation

The first milestone stores the incremental buffer as a PureBasic string. It correctly handles complete valid UTF-8 body strings, but future transport-specific readers should move to a byte-buffer implementation before accepting arbitrary raw socket or pipe bytes that may split inside a UTF-8 sequence.
