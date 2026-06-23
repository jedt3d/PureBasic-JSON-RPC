# JSON-RPC Compliance Matrix

This matrix maps JSON-RPC 2.0 behavior to the PureBasic implementation and
tests. It is intentionally focused on the reusable `JSONRPC_*` library. MCP
adapter behavior can rely on this foundation, but MCP schemas are not part of
this matrix.

Reference: https://www.jsonrpc.org/specification

## Coverage Summary

| Area | Requirement | Implementation | Test Evidence | Status |
| --- | --- | --- | --- | --- |
| Version | Messages must use `jsonrpc: "2.0"` | `src/jsonrpc/protocol.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Request | Request object has `method` string and optional structured `params` | `src/jsonrpc/protocol.pbi`, `src/jsonrpc/dispatch.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/005_dispatch.pb` | Covered |
| Notification | Request without `id` is a notification and produces no response | `src/jsonrpc/protocol.pbi`, `src/jsonrpc/dispatch.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/005_dispatch.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Response | Response has exactly one of `result` or `error` | `src/jsonrpc/protocol.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Error object | Standard error responses include `code`, `message`, and original or null `id` | `src/jsonrpc/protocol.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Parse error | Invalid JSON returns `-32700` with `id: null` | `src/jsonrpc/protocol.pbi`, `src/jsonrpc/dispatch.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Invalid request | Invalid request shape returns `-32600` | `src/jsonrpc/protocol.pbi`, `src/jsonrpc/batch.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Invalid id | Object, array, and boolean ids are rejected with `-32600` and `id: null` | `src/jsonrpc/protocol.pbi` | `tests/unit/029_negative_tests.pb` | Covered |
| Method not found | Unknown request returns `-32601` | `src/jsonrpc/dispatch.pbi` | `tests/unit/005_dispatch.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Invalid params | Invalid `params` shape returns `-32602` | `src/jsonrpc/protocol.pbi`, `src/jsonrpc/dispatch.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/005_dispatch.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Id values | String, number, and null ids are preserved when detectable | `src/jsonrpc/protocol.pbi` | `tests/unit/004_protocol_errors.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Batch empty | Empty batch returns invalid request | `src/jsonrpc/batch.pbi` | `tests/unit/008_batch_handling.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Batch mixed | Mixed batch returns only required responses | `src/jsonrpc/batch.pbi` | `tests/unit/008_batch_handling.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Batch notifications | Notification-only batch produces no response | `src/jsonrpc/batch.pbi` | `tests/unit/008_batch_handling.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Batch invalid item | Invalid batch item produces an invalid-request response in the response array | `src/jsonrpc/batch.pbi` | `tests/unit/024_compliance_suite.pb` | Covered |
| Outbound matching | Response ids match pending outbound requests | `src/jsonrpc/outbound.pbi` | `tests/unit/006_outbound_requests.pb`, `tests/unit/024_compliance_suite.pb` | Covered |
| Orphan response | Unmatched responses are rejected and counted | `src/jsonrpc/outbound.pbi`, `src/jsonrpc/diagnostics.pbi` | `tests/unit/006_outbound_requests.pb`, `tests/unit/024_compliance_suite.pb` | Covered |

## Known Boundaries

- The matrix does not claim transport-level byte stream completeness. Transport
  framing and stdio behavior are covered separately by framing, codec, and
  runtime tests.
- The base JSON-RPC specification does not define cancellation, progress,
  tracing, or MCP tools. Those are extension or adapter behaviors.
- Null request ids are accepted because JSON-RPC permits null ids, while also
  discouraging them because they can be confused with unknown-id error
  responses.

## Required Maintenance

When JSON-RPC behavior changes:

- update the implementation row in this matrix
- update or add PureUnit coverage
- update `JSONRPC_Compliance_RunCore()` if the behavior belongs in the reusable
  compliance runner
- update the related API page and milestone entry
