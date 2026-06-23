# 005 Dispatch

Milestone `005-dispatch` adds request and notification handler registration and dispatch.

## Include

```purebasic
XIncludeFile "src/jsonrpc/dispatch.pbi"
```

## Public Structures

```purebasic
Prototype.i JSONRPC_RequestHandler(paramsValue, *context, *result)
Prototype.i JSONRPC_NotificationHandler(paramsValue, *context)

Structure JSONRPC_RequestContext
  method.s
  idText.s
  hasId.i
  *connection.JSONRPC_Connection
EndStructure

Structure JSONRPC_HandlerResult
  ok.i
  resultJson.s
  errorCode.i
  errorMessage.s
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Dispatcher_Init(*dispatcher)
JSONRPC_RegisterRequest(*dispatcher, method.s, *handler)
JSONRPC_RegisterNotification(*dispatcher, method.s, *handler)
JSONRPC_Dispatcher_Dispatch(*dispatcher, *connection, body.s)
JSONRPC_Dispatcher_DispatchToConnection(*dispatcher, *connection, body.s)
```

## Behavior

- Request handlers return either a JSON result fragment or a JSON-RPC error.
- Notification handlers are called without producing a response.
- Unknown requests return `-32601 Method not found`.
- Unknown notifications produce no response.
- `paramsValue` is valid only during the handler call; copy any values needed later.

The examples use MCP-flavored generic method names such as `tools/echo` and `notifications/log`, while the core dispatcher remains JSON-RPC generic.

