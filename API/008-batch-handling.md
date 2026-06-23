# 008 Batch Handling

Milestone `008-batch-handling` adds sequential JSON-RPC batch dispatch.

## Include

```purebasic
XIncludeFile "src/jsonrpc/batch.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Batch_IsBatch(body.s)
JSONRPC_Batch_Dispatch(*dispatcher, *connection, body.s)
JSONRPC_Batch_DispatchToConnection(*dispatcher, *connection, body.s)
```

## Behavior

- Batch items are processed sequentially using the existing dispatcher.
- Empty batch returns `-32600 Invalid Request` with `id: null`.
- Notifications inside a batch run but produce no response entry.
- A notification-only batch returns an empty string, meaning no protocol response.
- Mixed batches return a JSON array containing only required responses.
