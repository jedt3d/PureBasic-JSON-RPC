# 028 Compliance Matrix

Milestone `028-compliance-matrix` expands the reusable JSON-RPC compliance
runner and adds a traceable matrix from JSON-RPC 2.0 behavior to implementation
and tests.

## Include

```purebasic
XIncludeFile "src/jsonrpc/compliance.pbi"
```

The consolidated include also exposes the compliance runner:

```purebasic
XIncludeFile "src/jsonrpc/jsonrpc.pbi"
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

## Expanded Coverage

The compliance runner now covers:

- official-style request examples
- notification no-response behavior
- unknown method errors
- invalid request shape
- invalid params shape
- null id preservation
- invalid JSON-RPC version
- parse errors with `id: null`
- response result/error exclusivity
- error responses with string ids
- empty batches
- invalid batch items
- notification-only batches
- mixed batches
- outbound response matching
- orphan response rejection and diagnostics

## Matrix Document

The traceable compliance matrix lives at:

```text
docs/jsonrpc-compliance-matrix.md
```

## Scenario

```text
examples/028-compliance-matrix/compliance_matrix_probe.pb
```

The scenario runs `JSONRPC_Compliance_RunCore()` and verifies that the expanded
suite reports at least the expected matrix coverage count.
