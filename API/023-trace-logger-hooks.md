# 023 Trace Logger Hooks

Milestone `023-trace-logger-hooks` adds transport-safe trace capture and optional callback logging.

## Include

```purebasic
XIncludeFile "src/jsonrpc/trace.pbi"
```

## Trace Levels

```purebasic
#JSONRPC_Trace_Off
#JSONRPC_Trace_Errors
#JSONRPC_Trace_Headers
#JSONRPC_Trace_Messages
#JSONRPC_Trace_Verbose
```

## Public Procedures

```purebasic
Prototype JSONRPC_TraceLogger(*connection, traceLevel.i, message.s)

JSONRPC_Trace_Set(*connection, traceLevel.i, includePayloads.i = #False)
JSONRPC_Trace_SetLogger(*connection, logger)
JSONRPC_Trace_Log(*connection, traceLevel.i, message.s)
JSONRPC_Trace_GetCaptured(*connection)
JSONRPC_Trace_Clear(*connection)
```

## Behavior

- Tracing is off by default.
- Trace data is captured on the connection and can also be delivered to a callback.
- The library does not print trace output to stdout.
- Payloads are hidden by default.
- Passing `includePayloads = #True` allows body-level message tracing.
- Write failures are available at `#JSONRPC_Trace_Errors`.
