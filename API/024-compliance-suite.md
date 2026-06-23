# 024 Compliance Suite

Milestone `024-compliance-suite` adds a reusable JSON-RPC core compliance runner.

## Include

```purebasic
XIncludeFile "src/jsonrpc/compliance.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_ComplianceReport
  passed.i
  failed.i
  lastFailure.s
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Compliance_Reset(*report)
JSONRPC_Compliance_Assert(*report, condition.i, failure.s)
JSONRPC_Compliance_RunCore(*report)
JSONRPC_Compliance_Summary(*report)
```

## Coverage

- Official-style `subtract` request examples.
- Notifications produce no response.
- Unknown methods return `-32601`.
- Parse errors return `-32700` and `id: null`.
- Empty batches return `-32600`.
- Notification-only batches produce no response.
- Mixed batches return only required responses.
- Response ids match pending outbound requests.

The suite is intentionally generic and does not include MCP schemas or MCP-specific methods.
