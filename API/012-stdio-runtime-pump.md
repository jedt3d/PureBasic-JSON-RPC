# 012 Stdio Runtime Pump

Milestone `012-stdio-runtime-pump` adds a reusable stdio message pump.

## Include

```purebasic
XIncludeFile "src/jsonrpc/stdio_runtime.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_StdioRuntime
  reader.JSONRPC_Codec_StdioReader
  processedMessages.i
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_StdioRuntime_Init(*runtime, maxMessageBytes.i = #JSONRPC_Codec_DefaultMaxMessageBytes)
JSONRPC_StdioRuntime_Feed(*runtime, *dispatcher, *connection, chunk.s)
JSONRPC_StdioRuntime_ProcessMessage(*dispatcher, *connection, body.s)
```

## Behavior

- Feed accepts arbitrary chunks and processes all complete newline-delimited stdio messages.
- Requests and notifications are dispatched through the existing dispatcher.
- Batch messages are dispatched through the batch layer.
- Responses are matched against pending outbound requests.
- Cancellation notifications record cooperative cancellation tokens.
