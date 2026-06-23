# 022 Write Queue Close Semantics

Milestone `022-write-queue-close-semantics` adds an explicit queued write path behind connection sending.

## Include

```purebasic
XIncludeFile "src/jsonrpc/connection.pbi"
```

## Public Procedures

```purebasic
JSONRPC_Connection_QueueBody(*connection, body.s)
JSONRPC_Connection_FlushWrites(*connection)
JSONRPC_Connection_PendingWriteCount(*connection)
JSONRPC_Connection_SendBody(*connection, body.s)
```

## Diagnostics

`JSONRPC_Diagnostics` now includes:

```purebasic
queuedWrites.q
writeFailures.q
```

## Behavior

- `JSONRPC_Connection_SendBody()` queues and immediately flushes one body.
- `JSONRPC_Connection_QueueBody()` lets tests and future transports stage writes before flushing.
- Successful flushes increment `sentMessages`.
- Failed writes increment `writeFailures`, set `#JSONRPC_Connection_ErrorWriteFailed`, and drop the failed queued body.
- Closing a connection clears queued writes.
- Writes during or after close are rejected with `#JSONRPC_Connection_ErrorClosed`.
