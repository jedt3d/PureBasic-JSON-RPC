# 018 Byte Buffer Framing

Milestone `018-byte-buffer-framing` adds an explicit byte-buffer helper and routes the framing and stdio codec states through it.

## Include

```purebasic
XIncludeFile "src/jsonrpc/byte_buffer.pbi"
```

The existing codec includes also expose the helper:

```purebasic
XIncludeFile "src/jsonrpc/framing.pbi"
XIncludeFile "src/jsonrpc/codec.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_ByteBuffer
  text.s
  byteLength.i
  maxBytes.i
  overflow.i
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_ByteBuffer_Init(*buffer, maxBytes.i = 0)
JSONRPC_ByteBuffer_Clear(*buffer)
JSONRPC_ByteBuffer_SetText(*buffer, text.s)
JSONRPC_ByteBuffer_AppendUtf8(*buffer, chunk.s)
JSONRPC_ByteBuffer_AsText(*buffer)
JSONRPC_ByteBuffer_Length(*buffer)
JSONRPC_ByteBuffer_HasOverflow(*buffer)
```

## Behavior

- Byte length is counted with PureBasic UTF-8 byte length semantics.
- Rejected appends set an overflow flag and leave existing content unchanged.
- `JSONRPC_FrameState` now stores its incremental buffer as `JSONRPC_ByteBuffer`.
- `JSONRPC_StdioCodecState` now stores its incremental buffer as `JSONRPC_ByteBuffer`.
- The external framing and stdio codec procedure names remain compatible.

## Limit

PureBasic string input is still expected to be valid text. This round makes buffering state explicit and bounded, but raw OS byte streams should still enter through transport-specific adapters that decode complete UTF-8 message bodies.
