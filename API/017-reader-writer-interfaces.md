# 017 Reader Writer Interfaces

Milestone `017-reader-writer-interfaces` adds transport-neutral reader and writer structures.

## Include

```purebasic
XIncludeFile "src/jsonrpc/io.pbi"
```

The consolidated connection include also exposes these structures:

```purebasic
XIncludeFile "src/jsonrpc/connection.pbi"
```

## Public Structures

```purebasic
Structure JSONRPC_Writer
  captured.s
  writeCount.i
  closed.i
EndStructure

Structure JSONRPC_FakeWriter Extends JSONRPC_Writer
EndStructure

Structure JSONRPC_Reader
  buffer.s
  readCount.i
  closed.i
EndStructure
```

## Public Procedures

```purebasic
JSONRPC_Writer_Init(*writer)
JSONRPC_Writer_Write(*writer, body.s)
JSONRPC_Writer_Close(*writer)
JSONRPC_Writer_IsClosed(*writer)
JSONRPC_Writer_GetCaptured(*writer)
JSONRPC_Writer_GetWriteCount(*writer)
JSONRPC_Writer_FailNextWrite(*writer)

JSONRPC_Reader_Init(*reader)
JSONRPC_Reader_PushBytes(*reader, chunk.s)
JSONRPC_Reader_ReadAvailable(*reader)
JSONRPC_Reader_Close(*reader)
JSONRPC_Reader_IsClosed(*reader)
```

## Behavior

- `JSONRPC_Connection` now stores a generic `JSONRPC_Writer`.
- `JSONRPC_FakeWriter` remains as a compatibility alias for existing tests and examples.
- The generic reader is an in-memory test fixture for future transport pumps.
- A closed writer rejects new writes.
- `JSONRPC_Writer_FailNextWrite()` lets tests simulate a failed write without depending on OS streams.
