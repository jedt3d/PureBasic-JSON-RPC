# 006 Outbound Requests

Milestone `006-outbound-requests` adds outbound request ids, notification sends, and pending response matching.

## Include

```purebasic
XIncludeFile "src/jsonrpc/outbound.pbi"
```

`outbound.pbi` includes the lower protocol and connection layers.

## Public Procedures

```purebasic
JSONRPC_Connection_SendRequest(*connection, method.s, paramsJson.s = "")
JSONRPC_Connection_SendNotification(*connection, method.s, paramsJson.s = "")
JSONRPC_Connection_MatchResponse(*connection, body.s)
JSONRPC_Connection_PendingCount(*connection)
JSONRPC_Connection_HasPending(*connection, idText.s)
JSONRPC_Connection_GetNextId(*connection)
JSONRPC_Connection_GetLastMatchedIdText(*connection)
JSONRPC_Connection_GetLastResponseBody(*connection)

JSONRPC_Protocol_IsValidParamsJson(paramsJson.s)
JSONRPC_Protocol_BuildRequest(method.s, paramsJson.s, idText.s)
JSONRPC_Protocol_BuildNotification(method.s, paramsJson.s)
```

## Behavior

- `JSONRPC_Connection_SendRequest()` assigns the next numeric id, writes the request body, and records a pending request only when the write succeeds.
- `JSONRPC_Connection_SendNotification()` writes a notification without consuming an id or creating pending state.
- `paramsJson` may be omitted. When present, it must parse as a JSON object or array.
- `JSONRPC_Connection_MatchResponse()` accepts only valid JSON-RPC response objects whose `id` matches a pending request.
- Matching responses remove the pending entry and record the raw response body for the caller.
- Orphan responses are ignored and leave existing pending requests untouched.
- `JSONRPC_Connection_Close()` clears pending requests.

The API is generic JSON-RPC. The example method names use MCP-flavored names such as `tools/list` and `notifications/log` to keep the future MCP server workflow visible without adding MCP schemas yet.

## JSON-RPC Notes

JSON-RPC request ids correlate requests and responses. Notifications omit `id` and must not receive responses. Response ids must match the request id.
