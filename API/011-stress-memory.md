# 011 Stress And Memory Lifecycle

Milestone `011-stress-memory` adds bounded stress coverage for repeated parse, dispatch, timeout, and cancellation paths.

## Include

```purebasic
XIncludeFile "src/jsonrpc/stress.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Stress_RunBasic(*dispatcher, *connection, iterations.i)
```

## Behavior

- The stress helper repeatedly exercises malformed input, unknown methods, notification-only batches, outbound timeout cleanup, and cancellation cleanup.
- It returns `#True` only when no pending request state remains after each iteration.
- This milestone adds test coverage for memory lifecycle discipline; it does not add a new protocol wire shape.
