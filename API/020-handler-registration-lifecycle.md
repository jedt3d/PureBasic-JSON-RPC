# 020 Handler Registration Lifecycle

Milestone `020-handler-registration-lifecycle` formalizes handler replacement, unregister, and catch-all dispatch behavior.

## Include

```purebasic
XIncludeFile "src/jsonrpc/dispatch.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Dispatcher_SetReplaceHandlers(*dispatcher, replaceHandlers.i)

JSONRPC_RegisterRequest(*dispatcher, method.s, *handler)
JSONRPC_RegisterNotification(*dispatcher, method.s, *handler)
JSONRPC_RegisterStarRequest(*dispatcher, *handler)
JSONRPC_RegisterStarNotification(*dispatcher, *handler)

JSONRPC_UnregisterRequest(*dispatcher, method.s)
JSONRPC_UnregisterNotification(*dispatcher, method.s)
JSONRPC_Dispatcher_HasRequest(*dispatcher, method.s)
JSONRPC_Dispatcher_HasNotification(*dispatcher, method.s)
```

## Behavior

- Duplicate registrations replace existing handlers by default.
- `JSONRPC_Dispatcher_SetReplaceHandlers(*dispatcher, #False)` rejects duplicate method registration.
- Unregistering a missing handler returns `#False`.
- Exact request and notification handlers are preferred over catch-all handlers.
- Unknown requests still return `-32601 Method not found` when no catch-all request handler exists.
- Unknown notifications still produce no JSON-RPC response.
