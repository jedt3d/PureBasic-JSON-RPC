# 019 Connection Events

Milestone `019-connection-events` adds optional connection lifecycle and protocol event observation.

## Include

```purebasic
XIncludeFile "src/jsonrpc/connection.pbi"
```

## Event Codes

```purebasic
#JSONRPC_Connection_EventError
#JSONRPC_Connection_EventMalformedMessage
#JSONRPC_Connection_EventUnhandledNotification
#JSONRPC_Connection_EventOrphanResponse
#JSONRPC_Connection_EventClose
#JSONRPC_Connection_EventDispose
```

## Public Procedures

```purebasic
Prototype JSONRPC_ConnectionEventHandler(*connection, eventCode.i, detail.s)

JSONRPC_Connection_SetEventHandler(*connection, handler)
JSONRPC_Connection_EmitEvent(*connection, eventCode.i, detail.s)
JSONRPC_Connection_GetLastEventCode(*connection)
JSONRPC_Connection_GetLastEventDetail(*connection)
JSONRPC_Connection_GetEventCount(*connection)
```

## Behavior

- Event handlers are optional.
- The connection records the last event even when no callback is registered.
- Malformed messages, unhandled notifications, orphan responses, errors, and close are observable.
- Event detail strings are short diagnostic hints, not owned JSON values.
- Existing dispatch behavior remains unchanged.
