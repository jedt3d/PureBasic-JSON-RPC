# 003 Connection Lifecycle

Milestone `003-connection-lifecycle` adds the first connection state object and a fake writer for deterministic testing.

## Include

```purebasic
XIncludeFile "src/jsonrpc/connection.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_FakeWriter
  captured.s
  writeCount.i
  closed.i
EndStructure

Structure JSONRPC_Connection
  running.i
  closing.i
  closed.i
  writerMutex.i
  *writer.JSONRPC_FakeWriter
  lastErrorCode.i
  lastErrorMessage.s
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_FakeWriter_Init(*writer)
JSONRPC_FakeWriter_Close(*writer)
JSONRPC_Connection_Init(*connection, *writer)
JSONRPC_Connection_Close(*connection)
JSONRPC_Connection_SendBody(*connection, body.s)
JSONRPC_Connection_IsRunning(*connection)
JSONRPC_Connection_IsClosing(*connection)
JSONRPC_Connection_IsClosed(*connection)
JSONRPC_Connection_GetLastErrorCode(*connection)
JSONRPC_Connection_GetLastErrorMessage(*connection)
```

## Behavior

- A connection starts in `running` state after successful initialization.
- Closing is idempotent and closes the fake writer.
- The writer mutex protects outbound body writes.
- Writes after close fail with `#JSONRPC_Connection_ErrorClosed`.
- This milestone does not parse JSON or dispatch handlers.

