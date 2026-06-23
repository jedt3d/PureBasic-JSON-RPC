# 021 Handler Cancellation Tokens

Milestone `021-handler-cancellation-tokens` exposes cooperative cancellation state to request handlers.

## Include

```purebasic
XIncludeFile "src/jsonrpc/cancel.pbi"
```

## Request Context Additions

```purebasic
Structure JSONRPC_RequestContext
  cancellationIdText.s
  cancellationRequested.i
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_RequestContext_IsCancellationRequested(*context)
JSONRPC_RequestContext_CancellationId(*context)
JSONRPC_Connection_IsCancellationRequested(*connection, idText.s)
JSONRPC_Connection_ClearCancellation(*connection, idText.s)
```

## Behavior

- `$/cancelRequest` still records cooperative cancellation state.
- Request handlers can check cancellation through their context.
- Cancellation does not stop or kill handler execution.
- Completing a request clears matching cancellation state.
- Cancellation notifications still produce no JSON-RPC response.
