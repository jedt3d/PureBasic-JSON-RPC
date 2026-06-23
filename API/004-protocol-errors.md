# 004 Protocol Errors

Milestone `004-protocol-errors` adds JSON-RPC 2.0 parse, validation, and response-building helpers.

## Include

```purebasic
XIncludeFile "src/jsonrpc/protocol.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_ProtocolResult
  valid.i
  messageType.i
  requiresResponse.i
  method.s
  idText.s
  hasId.i
  errorCode.i
  errorMessage.s
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Protocol_ResetResult(*result)
JSONRPC_Protocol_Inspect(body.s, *result)
JSONRPC_Protocol_BuildErrorResponse(errorCode.i, message.s, idText.s)
JSONRPC_Protocol_BuildResultResponse(resultJson.s, idText.s)
JSONRPC_Protocol_BuildMethodNotFoundResponse(idText.s)
```

## Behavior

- Invalid JSON produces `-32700` with `id: null`.
- Invalid request shapes produce `-32600`.
- Invalid `params` shape produces `-32602`.
- Valid notifications do not require responses.
- Valid responses must contain exactly one of `result` or `error`.
- Detected request ids are preserved in error responses where possible.

Every `ParseJSON()` path frees its JSON handle before returning.

