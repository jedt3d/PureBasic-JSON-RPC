# 007 Timeout Housekeeping

Milestone `007-timeout-housekeeping` adds pending outbound request timeout cleanup.

## Include

```purebasic
XIncludeFile "src/jsonrpc/outbound.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Connection_SendRequest(*connection, method.s, paramsJson.s = "", timeoutMs.i = #JSONRPC_Connection_DefaultTimeoutMs)
JSONRPC_Connection_CleanupTimeouts(*connection, nowMs.q)
JSONRPC_Connection_GetLastTimedOutIdText(*connection)
JSONRPC_Connection_PendingDeadline(*connection, idText.s)
```

## Behavior

- Pending requests record creation time, timeout duration, and deadline.
- The default timeout is `30000` milliseconds.
- A non-positive timeout override falls back to the default.
- `JSONRPC_Connection_CleanupTimeouts()` removes expired pending requests and returns the number removed.
- Matching a response removes the pending request before timeout cleanup can expire it.
