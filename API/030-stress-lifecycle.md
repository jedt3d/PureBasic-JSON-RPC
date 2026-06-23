# 030 Stress Lifecycle

Milestone `030-stress-lifecycle` expands repeated-use testing for connection,
dispatch, timeout, cancellation, trace, write, and close lifecycle behavior.

## Include

```purebasic
XIncludeFile "src/jsonrpc/stress.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Stress_RunBasic(*dispatcher, *connection, iterations.i)
JSONRPC_Stress_RunLifecycle(*dispatcher, *connection, iterations.i)
```

## Behavior

`JSONRPC_Stress_RunLifecycle()` repeatedly exercises:

- unknown request dispatch
- notification-only batch dispatch
- queued writes and flush
- outbound request timeout cleanup
- cooperative cancellation request and clear
- trace capture clear
- pending request and queued-write cleanup

It returns `#True` only when every iteration leaves the connection in the
expected bounded state.

## Scenario

```text
examples/030-stress-lifecycle/stress_lifecycle_probe.pb
```

The scenario runs the lifecycle stress helper against a real in-memory writer.
