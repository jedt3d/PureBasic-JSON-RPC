# 009 Cooperative Cancellation

Milestone `009-cancellation` adds cooperative `$/cancelRequest` support.

## Include

```purebasic
XIncludeFile "src/jsonrpc/cancel.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Cancel_ProcessNotification(*connection, body.s)
JSONRPC_Cancel_Request(*connection, idText.s)
JSONRPC_Cancel_IsRequested(*connection, idText.s)
JSONRPC_Cancel_Clear(*connection, idText.s)
JSONRPC_Cancel_GetLastCancelledIdText(*connection)
```

## Behavior

- `$/cancelRequest` is a notification and never produces a JSON-RPC response.
- Cancellation records an id token in the connection.
- Handlers can query the token cooperatively and decide when to stop work.
- Cancellation does not terminate threads or interrupt procedures.
- Connection close clears cancellation tokens.
